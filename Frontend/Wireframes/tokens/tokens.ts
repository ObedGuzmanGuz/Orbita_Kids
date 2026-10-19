// Órbita Kids · Design tokens WEB (React + Vite). 1rem = 16px. Generado por tools/export_specs.py

export const px = (v: number) => `${v}px`;
export const rem = (v: number) => `${v / 16}rem`;

export const tokens = {
  spacing: {
    xxs: '0.25rem', // 4px
    xs: '0.5rem', // 8px
    sm: '0.75rem', // 12px
    md: '1rem', // 16px
    lg: '1.25rem', // 20px
    xl: '1.5rem', // 24px
    xxl: '2rem', // 32px
  },
  radius: {
    card: '0.75rem', // 12px
    button: '0.625rem', // 10px
    row: '0.625rem', // 10px
    input: '0.5rem', // 8px
    doc: '0.25rem', // 4px
    checkbox: '0.25rem', // 4px
    track: '0.25rem', // 4px
    chip: '1.125rem', // 18px
    search: '1.5rem', // 24px
    searchHeader: '1.375rem', // 22px
    switchTrack: '0.75rem', // 12px
  },
  size: {
    button: '3rem', // 48px
    input: '3rem', // 48px
    textarea: '6rem', // 96px
    chip: '2.25rem', // 36px
    cellButton: '1.75rem', // 28px
    icon: '1.5rem', // 24px
    iconSm: '1.25rem', // 20px
    iconMd: '2rem', // 32px
    iconXl: '3.5rem', // 56px
    avatar: '2.5rem', // 40px
    avatarAppBar: '2rem', // 32px
    avatarLg: '4.5rem', // 72px
    stepBadge: '1.5rem', // 24px
    radio: '1.25rem', // 20px
    radioDot: '0.625rem', // 10px
    radioRubric: '1.125rem', // 18px
    checkbox: '1.25rem', // 20px
    switchW: '2.75rem', // 44px
    switchH: '1.5rem', // 24px
    switchThumb: '1rem', // 16px
    progress: '0.5rem', // 8px
    timerRing: '7.25rem', // 116px
    playButton: '3.5rem', // 56px
    rowList: '4rem', // 64px
    rowToggle: '3.5rem', // 56px
    rowCheck: '3.25rem', // 52px
    rowTable: '2.75rem', // 44px
    rowStepMobile: '2.75rem', // 44px
    rowStepWeb: '3rem', // 48px
    tapTarget: '3rem', // 48px
  },
  type: {
    h1Web: { fontSize: '1.75rem', lineHeight: '2.25rem', fontWeight: 700 }, // 28/36px
    h1Mobile: { fontSize: '1.375rem', lineHeight: '1.75rem', fontWeight: 700 }, // 22/28px
    h2: { fontSize: '1.25rem', lineHeight: '1.75rem', fontWeight: 700 }, // 20/28px
    timer: { fontSize: '1.625rem', lineHeight: '2rem', fontWeight: 700 }, // 26/32px
    statValue: { fontSize: '1.75rem', lineHeight: '2.25rem', fontWeight: 700 }, // 28/36px
    cardTitle: { fontSize: '1.0625rem', lineHeight: '1.5rem', fontWeight: 700 }, // 17/24px
    brandWeb: { fontSize: '1rem', lineHeight: '1.375rem', fontWeight: 700 }, // 16/22px
    title: { fontSize: '0.875rem', lineHeight: '1.25rem', fontWeight: 700 }, // 14/20px
    body: { fontSize: '0.8125rem', lineHeight: '1.125rem', fontWeight: 400 }, // 13/18px
    bodyStrong: { fontSize: '0.8125rem', lineHeight: '1.125rem', fontWeight: 700 }, // 13/18px
    small: { fontSize: '0.75rem', lineHeight: '1rem', fontWeight: 400 }, // 12/16px
    caption: { fontSize: '0.6875rem', lineHeight: '1rem', fontWeight: 400 }, // 11/16px
    label: { fontSize: '0.6875rem', lineHeight: '1rem', fontWeight: 700 }, // 11/16px
    nav: { fontSize: '0.625rem', lineHeight: '0.875rem', fontWeight: 400 }, // 10/14px
    paragraph: { fontSize: '0.875rem', lineHeight: '1.25rem', fontWeight: 400 }, // 14/20px
  },
  layout: {
    rootFontSize: 16,
    canvasW: 1280,
    canvasH: 800,
    header: 80,
    headerPaddingX: 24,
    headerPaddingY: 16,
    sidebar: 260,
    sidebarPadding: 16,
    sidebarItemW: 228,
    sidebarItemH: 44,
    sidebarItemGap: 8,
    main: 1020,
    mainPadding: 24,
    contentWidth: 972,
    blockGap: 24,
    gridColumns: 12,
    gridColumn: 59,
    gridGutter: 24,
    cardPadding: 16,
    heroPadding: 20,
    searchW: 420,
    searchH: 44,
    logoBox: 48,
    headerAvatar: 40,
  },
} as const;

// Uso con Tailwind (tailwind.config.ts → theme.extend):
export const tailwindExtend = {
  spacing: Object.fromEntries(Object.entries(tokens.spacing)),
  borderRadius: Object.fromEntries(Object.entries(tokens.radius)),
  fontSize: Object.fromEntries(Object.entries(tokens.type).map(([k, t]) => [k, [t.fontSize, { lineHeight: t.lineHeight, fontWeight: String(t.fontWeight) }]])),
  width: { sidebar: rem(260), content: rem(972), search: rem(420) },
  height: { header: rem(80), control: rem(48), chip: rem(36) },
};
