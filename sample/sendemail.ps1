[CmdletBinding()]
Param(
[Parameter(Mandatory=$True,Position=1)]
[string[]]$tostring,
[Parameter(Mandatory=$True,Position=2)]
[string]$from,
[Parameter(Mandatory=$True,Position=3)]
[string]$subject,
[Parameter(Mandatory=$True,Position=4)]
[string]$bodyfile,
[Parameter(Mandatory=$True,Position=5)]
[string]$smtpserver,
[Parameter(Mandatory=$True,Position=6)]
[string]$attachments
)

$body="<pre>$(cat $bodyfile|out-string)</pre>"
$toarray=$tostring -split ','

Send-MailMessage -To $toarray -From $from -Subject $subject -Body $body -SmtpServer $smtpserver -Attachments $attachments -BodyAsHtml
