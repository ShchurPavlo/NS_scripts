
if (-not $args[0]) {
	Write-Host "No argument!!!"
	exit 1
}


$csvFilePath = $args[0]


if (-not (Test-Path $csvFilePath)) {
    Write-Host "No such files: $csvFilePath"
    exit 1
}


try {
    $users = Import-Csv -Path $csvFilePath
	foreach ($user in $users) {
	try {
		if (Get-LocalUser -Name $user.login -ErrorAction SilentlyContinue) {
                Write-Host "User: '$($user.login)' already exist."
        }
		else {
				New-LocalUser -Name $user.login -Password (ConvertTo-SecureString $user.password -AsPlainText -Force) -FullName $user.fullname -Description $user.password -PasswordNeverExpires -UserMayNotChangePassword
                Write-Host "User: '$($user.login)' created."
            }
        }
	catch {
		 Write-Host "Created error:  $($_.Exception.Message)"
	}
	
	try {
		Add-LocalGroupMember -Group "Пользователи удаленного рабочего стола" -Member $user.login -ErrorAction Stop
		Add-LocalGroupMember -Group "Пользователи" -Member $user.login -ErrorAction Stop
        }
	catch {
		 Write-Host "Error adding '$($user.login)' to standart group  "
	}
	
	try {
		if (Get-LocalGroup -Name $user.group -ErrorAction SilentlyContinue){
		Add-LocalGroupMember -Group $user.group -Member $user.login -ErrorAction Stop
		}
		
		else {
			Write-Host "No such group: '$($user.group)'. Created it!"
			New-LocalGroup -Name $user.group
			Add-LocalGroupMember -Group $user.group -Member $user.login -ErrorAction Stop
			continue
		}
		}
	catch {
		Write-Host "Error adding '$($user.login)' to '$($user.group)'"
		}
	
	
	}
   
}
catch {
   Write-Host "CSV file read error"
}
