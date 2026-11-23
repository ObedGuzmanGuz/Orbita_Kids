param(
  [string]$Repository = 'ObedGuzmanGuz/Orbita_Kids'
)

$ErrorActionPreference = 'Stop'
$headers = @{ 'User-Agent' = 'OrbitaKids-Gantt'; 'Accept' = 'application/vnd.github+json' }
$base = "https://api.github.com/repos/$Repository"
$branches = Invoke-RestMethod -Uri "$base/branches?per_page=100" -Headers $headers
$unique = @{}

foreach ($branch in $branches) {
  $encodedBranch = [uri]::EscapeDataString($branch.name)
  $commits = Invoke-RestMethod -Uri "$base/commits?sha=$encodedBranch&per_page=100" -Headers $headers
  foreach ($commit in $commits) {
    if (-not $unique.ContainsKey($commit.sha)) {
      $unique[$commit.sha] = [ordered]@{
        sha = $commit.sha
        authorName = $commit.commit.author.name
        authorLogin = if ($commit.author) { $commit.author.login } else { $null }
        date = $commit.commit.author.date
        message = ($commit.commit.message -split "`n")[0]
        url = $commit.html_url
        branches = @()
      }
    }
    $unique[$commit.sha].branches += $branch.name
  }
}

$snapshot = [ordered]@{
  repository = $Repository
  fetchedAt = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
  source = 'GitHub REST API, ramas y sus historiales; SHA deduplicados'
  branches = @($branches | ForEach-Object {
    [ordered]@{
      name = $_.name
      url = "https://github.com/$Repository/tree/$($_.name)"
      sha = $_.commit.sha
    }
  })
  commits = @($unique.Values | Sort-Object { [DateTimeOffset]::Parse($_.date) } -Descending)
}

$output = Join-Path $PSScriptRoot 'github-snapshot.json'
$snapshot | ConvertTo-Json -Depth 8 | Set-Content -Encoding utf8 $output
Write-Host "Snapshot actualizado: $output"
Write-Host "Ramas: $($snapshot.branches.Count) · SHA únicos: $($snapshot.commits.Count) · $($snapshot.fetchedAt)"
