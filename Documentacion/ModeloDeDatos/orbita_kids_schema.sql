-- =====================================================================
--  Órbita Kids · Esquema de base de datos (MySQL 8.0.16+)
--  Generado a partir del Diccionario de datos.
--  Motor: InnoDB · Codificación: utf8mb4
-- =====================================================================

DROP SCHEMA IF EXISTS orbita_kids;
CREATE SCHEMA orbita_kids
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;
USE orbita_kids;

SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
-- ROL
-- ---------------------------------------------------------------------
CREATE TABLE ROL (
  id_rol  TINYINT     NOT NULL AUTO_INCREMENT COMMENT 'Identificador del rol',
  nombre  VARCHAR(30) NOT NULL                COMMENT 'Nombre del rol. Valores: Estudiante, Docente, Dirección',
  CONSTRAINT pk_rol        PRIMARY KEY (id_rol),
  CONSTRAINT uq_rol_nombre UNIQUE (nombre)
) ENGINE=InnoDB COMMENT='Catálogo de roles del sistema (Estudiante, Docente, Dirección)';

-- ---------------------------------------------------------------------
-- USUARIO
-- ---------------------------------------------------------------------
CREATE TABLE USUARIO (
  id_usuario     INT          NOT NULL AUTO_INCREMENT COMMENT 'Identificador del usuario',
  keycloak_id    CHAR(36)     NOT NULL                COMMENT 'ID del usuario en Keycloak; no se guardan contraseñas aquí',
  id_rol         TINYINT      NOT NULL                COMMENT 'Rol asignado; define permisos de estudiante o docente',
  nombre         VARCHAR(60)  NOT NULL                COMMENT 'Nombre(s) del usuario',
  apellidos      VARCHAR(80)  NOT NULL                COMMENT 'Apellidos del usuario',
  correo         VARCHAR(100) NULL                    COMMENT 'Correo electrónico (opcional: los niños pueden no tener)',
  activo         BOOLEAN      NOT NULL DEFAULT 1      COMMENT 'Estado de la cuenta: 1 = activa, 0 = desactivada',
  fecha_registro DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de alta',
  CONSTRAINT pk_usuario          PRIMARY KEY (id_usuario),
  CONSTRAINT uq_usuario_keycloak UNIQUE (keycloak_id),
  CONSTRAINT uq_usuario_correo   UNIQUE (correo),
  CONSTRAINT fk_usuario_rol      FOREIGN KEY (id_rol) REFERENCES ROL (id_rol)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_usuario_rol (id_rol)
) ENGINE=InnoDB COMMENT='Cuentas de acceso al sistema; la contraseña la gestiona Keycloak';

-- ---------------------------------------------------------------------
-- INSTITUCION
-- ---------------------------------------------------------------------
CREATE TABLE INSTITUCION (
  id_institucion INT          NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la institución',
  nombre         VARCHAR(120) NOT NULL                COMMENT 'Nombre de la escuela',
  clave_centro   VARCHAR(20)  NULL                    COMMENT 'Clave oficial del centro de trabajo, si se tiene',
  tipo_licencia  ENUM('gratuita','escolar') NOT NULL DEFAULT 'gratuita'
                 COMMENT 'Plan contratado. Gratuita = acceso limitado; escolar = licencia de pago',
  fecha_registro DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de alta',
  CONSTRAINT pk_institucion       PRIMARY KEY (id_institucion),
  CONSTRAINT uq_institucion_clave UNIQUE (clave_centro)
) ENGINE=InnoDB COMMENT='Escuelas que adoptan la plataforma';

-- ---------------------------------------------------------------------
-- DOCENTE (especialización de USUARIO)
-- ---------------------------------------------------------------------
CREATE TABLE DOCENTE (
  id_docente         INT NOT NULL COMMENT 'Identificador del docente (es el mismo id_usuario)',
  id_institucion     INT NULL     COMMENT 'Escuela a la que pertenece; nulo si aún no se vincula',
  estado_vinculacion ENUM('pendiente','aprobado','rechazado') NOT NULL DEFAULT 'pendiente'
                     COMMENT 'Estado de la solicitud ante la institución; la dirección aprueba o rechaza desde la PWA',
  CONSTRAINT pk_docente             PRIMARY KEY (id_docente),
  CONSTRAINT fk_docente_usuario     FOREIGN KEY (id_docente) REFERENCES USUARIO (id_usuario)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_docente_institucion FOREIGN KEY (id_institucion) REFERENCES INSTITUCION (id_institucion)
    ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_docente_institucion (id_institucion)
) ENGINE=InnoDB COMMENT='Perfil del docente (especialización de USUARIO)';

-- ---------------------------------------------------------------------
-- PERSONAJE
-- ---------------------------------------------------------------------
CREATE TABLE PERSONAJE (
  id_personaje INT          NOT NULL AUTO_INCREMENT COMMENT 'Identificador del personaje',
  nombre       VARCHAR(40)  NOT NULL                COMMENT 'Nombre del personaje. Ej. Orbi, Teo',
  imagen_url   VARCHAR(255) NOT NULL                COMMENT 'Ruta de la imagen',
  CONSTRAINT pk_personaje        PRIMARY KEY (id_personaje),
  CONSTRAINT uq_personaje_nombre UNIQUE (nombre)
) ENGINE=InnoDB COMMENT='Personajes que el estudiante puede elegir';

-- ---------------------------------------------------------------------
-- ESTUDIANTE (especialización de USUARIO)
-- ---------------------------------------------------------------------
CREATE TABLE ESTUDIANTE (
  id_estudiante  INT     NOT NULL COMMENT 'Identificador del estudiante (es el mismo id_usuario)',
  id_personaje   INT     NULL     COMMENT 'Personaje elegido; nulo hasta que lo elige',
  id_institucion INT     NULL     COMMENT 'Escuela del estudiante',
  grado          TINYINT NULL     COMMENT 'Grado de primaria (1 a 4)',
  edad           TINYINT NULL     COMMENT 'Edad del estudiante (6 a 9); se guarda lo mínimo por tratarse de menores',
  CONSTRAINT pk_estudiante             PRIMARY KEY (id_estudiante),
  CONSTRAINT fk_estudiante_usuario     FOREIGN KEY (id_estudiante) REFERENCES USUARIO (id_usuario)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_estudiante_personaje   FOREIGN KEY (id_personaje) REFERENCES PERSONAJE (id_personaje)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_estudiante_institucion FOREIGN KEY (id_institucion) REFERENCES INSTITUCION (id_institucion)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT ck_estudiante_grado CHECK (grado IS NULL OR grado BETWEEN 1 AND 4),
  CONSTRAINT ck_estudiante_edad  CHECK (edad  IS NULL OR edad  BETWEEN 6 AND 9),
  INDEX idx_estudiante_personaje (id_personaje),
  INDEX idx_estudiante_institucion (id_institucion)
) ENGINE=InnoDB COMMENT='Perfil del estudiante (especialización de USUARIO)';

-- ---------------------------------------------------------------------
-- GRUPO
-- ---------------------------------------------------------------------
CREATE TABLE GRUPO (
  id_grupo       INT         NOT NULL AUTO_INCREMENT COMMENT 'Identificador del grupo',
  id_docente     INT         NOT NULL                COMMENT 'Docente responsable',
  nombre         VARCHAR(60) NOT NULL                COMMENT 'Nombre del grupo. Ej. 2° A',
  ciclo_escolar  VARCHAR(9)  NOT NULL                COMMENT 'Ciclo escolar. Formato 2026-2027',
  codigo_acceso  VARCHAR(10) NOT NULL                COMMENT 'Código para que el estudiante se una al grupo',
  estado         ENUM('activo','archivado') NOT NULL DEFAULT 'activo'
                 COMMENT 'Estado del grupo; la PWA muestra grupos activos y archivados',
  fecha_creacion DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación',
  CONSTRAINT pk_grupo         PRIMARY KEY (id_grupo),
  CONSTRAINT uq_grupo_codigo  UNIQUE (codigo_acceso),
  CONSTRAINT fk_grupo_docente FOREIGN KEY (id_docente) REFERENCES DOCENTE (id_docente)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_grupo_ciclo   CHECK (ciclo_escolar REGEXP '^[0-9]{4}-[0-9]{4}$'),
  INDEX idx_grupo_docente (id_docente)
) ENGINE=InnoDB COMMENT='Grupos creados por los docentes';

-- ---------------------------------------------------------------------
-- GRUPO_ESTUDIANTE (N:M)
-- ---------------------------------------------------------------------
CREATE TABLE GRUPO_ESTUDIANTE (
  id_grupo      INT      NOT NULL COMMENT 'Grupo',
  id_estudiante INT      NOT NULL COMMENT 'Estudiante',
  fecha_ingreso DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha en que se unió al grupo',
  CONSTRAINT pk_grupo_estudiante PRIMARY KEY (id_grupo, id_estudiante),
  CONSTRAINT fk_ge_grupo      FOREIGN KEY (id_grupo) REFERENCES GRUPO (id_grupo)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ge_estudiante FOREIGN KEY (id_estudiante) REFERENCES ESTUDIANTE (id_estudiante)
    ON UPDATE CASCADE ON DELETE CASCADE,
  INDEX idx_ge_estudiante (id_estudiante)
) ENGINE=InnoDB COMMENT='Relación N:M entre grupos y estudiantes';

-- ---------------------------------------------------------------------
-- PLANETA
-- ---------------------------------------------------------------------
CREATE TABLE PLANETA (
  id_planeta INT          NOT NULL AUTO_INCREMENT COMMENT 'Identificador del planeta',
  nombre     VARCHAR(50)  NOT NULL                COMMENT 'Nombre del planeta',
  orden      TINYINT      NOT NULL                COMMENT 'Posición en el mapa; define la secuencia de exploración',
  imagen_url VARCHAR(255) NULL                    COMMENT 'Ilustración del planeta',
  CONSTRAINT pk_planeta        PRIMARY KEY (id_planeta),
  CONSTRAINT uq_planeta_nombre UNIQUE (nombre),
  CONSTRAINT uq_planeta_orden  UNIQUE (orden),
  CONSTRAINT ck_planeta_orden  CHECK (orden > 0)
) ENGINE=InnoDB COMMENT='Planetas del mapa espacial';

-- ---------------------------------------------------------------------
-- NIVEL
-- ---------------------------------------------------------------------
CREATE TABLE NIVEL (
  id_nivel    INT          NOT NULL AUTO_INCREMENT COMMENT 'Identificador del nivel',
  id_planeta  INT          NOT NULL                COMMENT 'Planeta al que pertenece',
  numero      TINYINT      NOT NULL                COMMENT 'Dificultad del nivel (1, 2 o 3)',
  descripcion VARCHAR(150) NULL                    COMMENT 'Descripción del nivel',
  CONSTRAINT pk_nivel         PRIMARY KEY (id_nivel),
  CONSTRAINT uq_nivel_planeta_numero UNIQUE (id_planeta, numero),
  CONSTRAINT fk_nivel_planeta FOREIGN KEY (id_planeta) REFERENCES PLANETA (id_planeta)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_nivel_numero  CHECK (numero BETWEEN 1 AND 3)
) ENGINE=InnoDB COMMENT='Niveles de dificultad por planeta';

-- ---------------------------------------------------------------------
-- MISION
-- ---------------------------------------------------------------------
CREATE TABLE MISION (
  id_mision   INT          NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la misión',
  id_planeta  INT          NOT NULL                COMMENT 'Planeta donde ocurre',
  nombre      VARCHAR(80)  NOT NULL                COMMENT 'Nombre de la misión',
  descripcion VARCHAR(255) NULL                    COMMENT 'Historia o instrucción de la misión',
  orden       TINYINT      NOT NULL                COMMENT 'Secuencia dentro del planeta',
  CONSTRAINT pk_mision         PRIMARY KEY (id_mision),
  CONSTRAINT uq_mision_planeta_orden UNIQUE (id_planeta, orden),
  CONSTRAINT fk_mision_planeta FOREIGN KEY (id_planeta) REFERENCES PLANETA (id_planeta)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_mision_orden   CHECK (orden > 0)
) ENGINE=InnoDB COMMENT='Misiones de reparación de la nave';

-- ---------------------------------------------------------------------
-- TIPO_ACTIVIDAD
-- ---------------------------------------------------------------------
CREATE TABLE TIPO_ACTIVIDAD (
  id_tipo TINYINT     NOT NULL AUTO_INCREMENT COMMENT 'Identificador del tipo',
  nombre  VARCHAR(40) NOT NULL                COMMENT 'Nombre del tipo: Suma con apoyo visual o Selección de respuesta',
  CONSTRAINT pk_tipo_actividad        PRIMARY KEY (id_tipo),
  CONSTRAINT uq_tipo_actividad_nombre UNIQUE (nombre)
) ENGINE=InnoDB COMMENT='Catálogo de tipos de actividad';

-- ---------------------------------------------------------------------
-- ACTIVIDAD
-- ---------------------------------------------------------------------
CREATE TABLE ACTIVIDAD (
  id_actividad       INT          NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la actividad',
  id_tipo            TINYINT      NOT NULL                COMMENT 'Tipo de actividad',
  id_nivel           INT          NOT NULL                COMMENT 'Nivel de dificultad',
  id_mision          INT          NULL                    COMMENT 'Misión donde aparece; nulo si es de refuerzo libre',
  sumando_a          SMALLINT     NOT NULL                COMMENT 'Primer sumando',
  sumando_b          SMALLINT     NOT NULL                COMMENT 'Segundo sumando',
  respuesta_correcta SMALLINT     NOT NULL                COMMENT 'Resultado de la suma; debe ser sumando_a + sumando_b',
  opciones           JSON         NULL                    COMMENT 'Opciones de respuesta; solo para selección de respuesta',
  apoyo_visual_url   VARCHAR(255) NULL                    COMMENT 'Imagen o recurso de apoyo visual',
  activa             BOOLEAN      NOT NULL DEFAULT 1      COMMENT 'Disponibilidad: 1 = disponible, 0 = oculta',
  CONSTRAINT pk_actividad        PRIMARY KEY (id_actividad),
  CONSTRAINT fk_actividad_tipo   FOREIGN KEY (id_tipo)   REFERENCES TIPO_ACTIVIDAD (id_tipo)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_actividad_nivel  FOREIGN KEY (id_nivel)  REFERENCES NIVEL (id_nivel)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_actividad_mision FOREIGN KEY (id_mision) REFERENCES MISION (id_mision)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT ck_actividad_suma      CHECK (respuesta_correcta = sumando_a + sumando_b),
  CONSTRAINT ck_actividad_sumandos  CHECK (sumando_a >= 0 AND sumando_b >= 0),
  INDEX idx_actividad_tipo (id_tipo),
  INDEX idx_actividad_nivel (id_nivel),
  INDEX idx_actividad_mision (id_mision)
) ENGINE=InnoDB COMMENT='Banco de sumas disponibles';

-- ---------------------------------------------------------------------
-- ASIGNACION
-- ---------------------------------------------------------------------
CREATE TABLE ASIGNACION (
  id_asignacion    INT          NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la asignación',
  id_grupo         INT          NOT NULL                COMMENT 'Grupo destinatario',
  id_docente       INT          NOT NULL                COMMENT 'Docente que asigna',
  titulo           VARCHAR(100) NOT NULL                COMMENT 'Título de la asignación',
  fecha_asignacion DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación',
  fecha_limite     DATE         NULL                    COMMENT 'Fecha límite de entrega',
  estado           ENUM('pendiente','activa','cerrada') NOT NULL DEFAULT 'pendiente'
                   COMMENT 'Estado de la asignación',
  CONSTRAINT pk_asignacion         PRIMARY KEY (id_asignacion),
  CONSTRAINT fk_asignacion_grupo   FOREIGN KEY (id_grupo)   REFERENCES GRUPO (id_grupo)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_asignacion_docente FOREIGN KEY (id_docente) REFERENCES DOCENTE (id_docente)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_asignacion_fechas  CHECK (fecha_limite IS NULL OR fecha_limite >= DATE(fecha_asignacion)),
  INDEX idx_asignacion_grupo (id_grupo),
  INDEX idx_asignacion_docente (id_docente)
) ENGINE=InnoDB COMMENT='Tareas que el docente asigna a un grupo';

-- ---------------------------------------------------------------------
-- ASIGNACION_ACTIVIDAD (N:M)
-- ---------------------------------------------------------------------
CREATE TABLE ASIGNACION_ACTIVIDAD (
  id_asignacion INT NOT NULL COMMENT 'Asignación',
  id_actividad  INT NOT NULL COMMENT 'Actividad incluida',
  CONSTRAINT pk_asignacion_actividad PRIMARY KEY (id_asignacion, id_actividad),
  CONSTRAINT fk_aa_asignacion FOREIGN KEY (id_asignacion) REFERENCES ASIGNACION (id_asignacion)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_aa_actividad  FOREIGN KEY (id_actividad)  REFERENCES ACTIVIDAD (id_actividad)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_aa_actividad (id_actividad)
) ENGINE=InnoDB COMMENT='Relación N:M entre asignaciones y actividades';

-- ---------------------------------------------------------------------
-- INTENTO
-- ---------------------------------------------------------------------
CREATE TABLE INTENTO (
  id_intento      BIGINT   NOT NULL AUTO_INCREMENT COMMENT 'Identificador del intento',
  id_estudiante   INT      NOT NULL                COMMENT 'Estudiante que responde',
  id_actividad    INT      NOT NULL                COMMENT 'Actividad resuelta',
  id_asignacion   INT      NULL                    COMMENT 'Asignación de origen; nulo si fue práctica libre',
  respuesta_dada  SMALLINT NULL                    COMMENT 'Respuesta del estudiante; nulo si no respondió',
  es_correcta     BOOLEAN  NOT NULL                COMMENT 'Resultado del intento: 1 = acierto, 0 = error',
  uso_apoyo       BOOLEAN  NOT NULL DEFAULT 0      COMMENT 'Indica si usó apoyo visual (sirve a las reglas de adaptación)',
  tiempo_segundos SMALLINT NULL                    COMMENT 'Tiempo empleado en segundos',
  fecha_hora      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Momento del intento',
  sincronizado    BOOLEAN  NOT NULL DEFAULT 0      COMMENT 'Si ya se envió al servidor (modo offline-first)',
  CONSTRAINT pk_intento PRIMARY KEY (id_intento),
  CONSTRAINT fk_intento_estudiante FOREIGN KEY (id_estudiante) REFERENCES ESTUDIANTE (id_estudiante)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_intento_actividad  FOREIGN KEY (id_actividad)  REFERENCES ACTIVIDAD (id_actividad)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_intento_asignacion FOREIGN KEY (id_asignacion) REFERENCES ASIGNACION (id_asignacion)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT ck_intento_tiempo CHECK (tiempo_segundos IS NULL OR tiempo_segundos >= 0),
  INDEX idx_intento_estudiante_fecha (id_estudiante, fecha_hora),
  INDEX idx_intento_actividad (id_actividad),
  INDEX idx_intento_asignacion (id_asignacion)
) ENGINE=InnoDB COMMENT='Registro de cada respuesta; base de reportes y errores frecuentes';

-- ---------------------------------------------------------------------
-- PROGRESO
-- ---------------------------------------------------------------------
CREATE TABLE PROGRESO (
  id_progreso         INT      NOT NULL AUTO_INCREMENT COMMENT 'Identificador del progreso',
  id_estudiante       INT      NOT NULL                COMMENT 'Estudiante (único junto con id_mision)',
  id_mision           INT      NOT NULL                COMMENT 'Misión evaluada',
  id_nivel_actual     INT      NOT NULL                COMMENT 'Nivel en que se encuentra; lo actualizan las reglas de adaptación',
  estado              ENUM('bloqueada','en_curso','completada') NOT NULL DEFAULT 'bloqueada'
                      COMMENT 'Estado de la misión',
  aciertos            INT      NOT NULL DEFAULT 0      COMMENT 'Aciertos acumulados',
  errores             INT      NOT NULL DEFAULT 0      COMMENT 'Errores acumulados',
  fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                      COMMENT 'Última actualización',
  CONSTRAINT pk_progreso PRIMARY KEY (id_progreso),
  CONSTRAINT uq_progreso_estudiante_mision UNIQUE (id_estudiante, id_mision),
  CONSTRAINT fk_progreso_estudiante FOREIGN KEY (id_estudiante)   REFERENCES ESTUDIANTE (id_estudiante)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_progreso_mision     FOREIGN KEY (id_mision)       REFERENCES MISION (id_mision)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_progreso_nivel      FOREIGN KEY (id_nivel_actual) REFERENCES NIVEL (id_nivel)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_progreso_contadores CHECK (aciertos >= 0 AND errores >= 0),
  INDEX idx_progreso_mision (id_mision),
  INDEX idx_progreso_nivel (id_nivel_actual)
) ENGINE=InnoDB COMMENT='Avance del estudiante por misión';

-- ---------------------------------------------------------------------
-- RECOMPENSA
-- ---------------------------------------------------------------------
CREATE TABLE RECOMPENSA (
  id_recompensa INT          NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la recompensa',
  id_mision     INT          NULL                    COMMENT 'Misión que la otorga',
  nombre        VARCHAR(60)  NOT NULL                COMMENT 'Nombre de la recompensa',
  imagen_url    VARCHAR(255) NULL                    COMMENT 'Imagen de la recompensa',
  CONSTRAINT pk_recompensa        PRIMARY KEY (id_recompensa),
  CONSTRAINT fk_recompensa_mision FOREIGN KEY (id_mision) REFERENCES MISION (id_mision)
    ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_recompensa_mision (id_mision)
) ENGINE=InnoDB COMMENT='Recompensas visuales (insignias, piezas de la nave)';

-- ---------------------------------------------------------------------
-- ESTUDIANTE_RECOMPENSA (N:M)
-- ---------------------------------------------------------------------
CREATE TABLE ESTUDIANTE_RECOMPENSA (
  id_estudiante   INT      NOT NULL COMMENT 'Estudiante',
  id_recompensa   INT      NOT NULL COMMENT 'Recompensa obtenida',
  fecha_obtencion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha en que la ganó',
  CONSTRAINT pk_estudiante_recompensa PRIMARY KEY (id_estudiante, id_recompensa),
  CONSTRAINT fk_er_estudiante FOREIGN KEY (id_estudiante) REFERENCES ESTUDIANTE (id_estudiante)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_er_recompensa FOREIGN KEY (id_recompensa) REFERENCES RECOMPENSA (id_recompensa)
    ON UPDATE CASCADE ON DELETE CASCADE,
  INDEX idx_er_recompensa (id_recompensa)
) ENGINE=InnoDB COMMENT='Relación N:M entre estudiantes y recompensas';

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- Datos iniciales de catálogos (según los valores del diccionario)
-- ---------------------------------------------------------------------
INSERT INTO ROL (nombre) VALUES ('Estudiante'), ('Docente'), ('Dirección');

INSERT INTO TIPO_ACTIVIDAD (nombre) VALUES
  ('Suma con apoyo visual'),
  ('Selección de respuesta');
