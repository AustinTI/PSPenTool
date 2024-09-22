Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "MyPTS (MyPenTestSuite)"
$form.Size = New-Object System.Drawing.Size(800, 600)

# Create the tab control
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Location = New-Object System.Drawing.Point(10, 10)
$tabControl.Size = New-Object System.Drawing.Size(760, 540)
$form.Controls.Add($tabControl)

# Create the reconnaissance tab
$reconTab = New-Object System.Windows.Forms.TabPage
$reconTab.Text = "Reconnaissance"
$tabControl.Controls.Add($reconTab)

# Create the network scanning tab
$networkTab = New-Object System.Windows.Forms.TabPage
$networkTab.Text = "Network Scanning"
$tabControl.Controls.Add($networkTab)

# Create the port scanning tab
$portTab = New-Object System.Windows.Forms.TabPage
$portTab.Text = "Port Scanning"
$tabControl.Controls.Add($portTab)

# Reconnaissance tab input and output fields
$reconInput = New-Object System.Windows.Forms.TextBox
$reconInput.Location = New-Object System.Drawing.Point(10, 50)
$reconInput.Size = New-Object System.Drawing.Size(300, 20)
$reconTab.Controls.Add($reconInput)

$reconOutput = New-Object System.Windows.Forms.TextBox
$reconOutput.Multiline = $true
$reconOutput.Location = New-Object System.Drawing.Point(10, 80)
$reconOutput.Size = New-Object System.Drawing.Size(740, 400)
$reconTab.Controls.Add($reconOutput)

$reconButton = New-Object System.Windows.Forms.Button
$reconButton.Text = "Start Reconnaissance"
$reconButton.Location = New-Object System.Drawing.Point(10, 10)
$reconTab.Controls.Add($reconButton)

# Network scanning tab output
$networkOutput = New-Object System.Windows.Forms.TextBox
$networkOutput.Multiline = $true
$networkOutput.Location = New-Object System.Drawing.Point(10, 50)
$networkOutput.Size = New-Object System.Drawing.Size(740, 400)
$networkTab.Controls.Add($networkOutput)

$networkButton = New-Object System.Windows.Forms.Button
$networkButton.Text = "Start Network Scan"
$networkButton.Location = New-Object System.Drawing.Point(10, 10)
$networkTab.Controls.Add($networkButton)

# Port scanning tab input and output fields
$portInput = New-Object System.Windows.Forms.TextBox
$portInput.Location = New-Object System.Drawing.Point(10, 50)
$portInput.Size = New-Object System.Drawing.Size(300, 20)
$portTab.Controls.Add($portInput)

$portOutput = New-Object System.Windows.Forms.TextBox
$portOutput.Multiline = $true
$portOutput.Location = New-Object System.Drawing.Point(10, 80)
$portOutput.Size = New-Object System.Drawing.Size(740, 400)
$portTab.Controls.Add($portOutput)

$portButton = New-Object System.Windows.Forms.Button
$portButton.Text = "Start Port Scan"
$portButton.Location = New-Object System.Drawing.Point(10, 10)
$portTab.Controls.Add($portButton)

# Event handling
$reconButton.Add_Click({
    $target = $reconInput.Text
    if (-not [string]::IsNullOrWhiteSpace($target)) {
        try {
            $response = Invoke-WebRequest -Uri $target -Method Get
            $reconOutput.Text = $response.Content
        } catch {
            $reconOutput.Text = "Error during reconnaissance: $_"
        }
    } else {
        $reconOutput.Text = "Please enter a valid URL."
    }
})

$networkButton.Add_Click({
    $networkOutput.Text = ""
    try {
        $neighbors = Get-NetNeighbor
        $networkOutput.Text += "Devices on the network:`n"
        foreach ($neighbor in $neighbors) {
            $networkOutput.Text += "$($neighbor.IPAddress)`n"
        }

        $printers = Get-Printer
        $networkOutput.Text += "Network printers:`n"
        foreach ($printer in $printers) {
            $networkOutput.Text += "$($printer.Name)`n"
        }
    } catch {
        $networkOutput.Text = "Error during network scan: $_"
    }
})

$portButton.Add_Click({
    $target = $portInput.Text
    if (-not [string]::IsNullOrWhiteSpace($target)) {
        $portOutput.Text = "Scanning open ports...`n"
        $ports = @()
        try {
            for ($i = 1; $i -le 65535; $i++) {
                $result = Test-NetConnection -ComputerName $target -Port $i
                if ($result.TcpTestSucceeded) {
                    $ports += $i
                }
            }
            $portOutput.Text = "Open ports:`n"
            foreach ($port in $ports) {
                $portOutput.Text += "$port`n"
            }
        } catch {
            $portOutput.Text = "Error during port scan: $_"
        }
    } else {
        $portOutput.Text = "Please enter a valid target IP or hostname."
    }
})

# Show the form
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
