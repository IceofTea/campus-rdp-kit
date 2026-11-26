param($h, $p, $ms = 2500)
try {
    $c = New-Object System.Net.Sockets.TcpClient
    $r = $c.BeginConnect($h, [int]$p, $null, $null)
    if (-not $r.AsyncWaitHandle.WaitOne([int]$ms)) { exit 1 }
    try { $c.EndConnect($r) } catch { exit 1 }
    $c.Close()
    exit 0
} catch { exit 1 }
