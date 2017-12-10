
while (0 -eq 0)
{
	Get-Date
	(new-object System.Net.WebClient).Downloadfile("http://localhost:3000/exec/index","out.html")
	Start-Sleep -s 50
}

