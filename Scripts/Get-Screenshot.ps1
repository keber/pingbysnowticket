param(
    [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        ParameterSetName='destinationPath')]
        [string]$destinationPath
)

Add-Type @"
 using System;
 using System.Runtime.InteropServices;

 public class User32 {
   [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();

   [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

   public struct RECT {
       public int Left;
       public int Top;
       public int Right;
       public int Bottom;
   }
 }
"@

Add-Type -AssemblyName System.Drawing

$hWnd = [User32]::GetForegroundWindow()
$rect = New-Object User32+RECT
[User32]::GetWindowRect($hWnd, [ref]$rect) | Out-Null

$width = $rect.Right - $rect.Left
$height = $rect.Bottom - $rect.Top

$bitmap = New-Object System.Drawing.Bitmap $width, $height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)

$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$filename = "Screenshot_$timestamp.png"
$destinationPath = $destinationPath.Trim()
$path = Join-Path -Path $destinationPath -ChildPath $fileName
$bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)

$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Screenshot guardado en $path"
#start $path