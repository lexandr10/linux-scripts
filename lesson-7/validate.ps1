# Script for project structure validation

Write-Host "=== Project Structure Validation ===" -ForegroundColor Green

# Check required files
$requiredFiles = @(
    "main.tf",
    "backend.tf",
    "outputs.tf",
    "variables.tf",
    "README.md",
    "terraform.tfvars.example"
)

Write-Host "`n1. Checking required files..." -ForegroundColor Yellow
$missingFiles = @()
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $file - missing!" -ForegroundColor Red
        $missingFiles += $file
    }
}

# Check modules
Write-Host "`n2. Checking Terraform modules..." -ForegroundColor Yellow
$modules = @("s3-backend", "vpc", "ecr", "eks")
foreach ($module in $modules) {
    $modulePath = "modules\$module"
    if (Test-Path $modulePath) {
        $tfFiles = Get-ChildItem -Path $modulePath -Filter "*.tf" -Recurse
        $fileCount = $tfFiles.Count
        if ($fileCount -gt 0) {
            Write-Host "  [OK] $module ($fileCount tf files)" -ForegroundColor Green
        } else {
            Write-Host "  [WARN] $module - no tf files" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [FAIL] $module - directory missing!" -ForegroundColor Red
        $missingFiles += $modulePath
    }
}

# Check Helm chart
Write-Host "`n3. Checking Helm chart..." -ForegroundColor Yellow
$chartPath = "charts\django-app"
if (Test-Path $chartPath) {
    $chartFiles = @("Chart.yaml", "values.yaml")
    foreach ($file in $chartFiles) {
        if (Test-Path "$chartPath\$file") {
            Write-Host "  [OK] $file" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] $file - missing!" -ForegroundColor Red
            $missingFiles += "$chartPath\$file"
        }
    }
    
    $templatesPath = "$chartPath\templates"
    if (Test-Path $templatesPath) {
        $requiredTemplates = @("deployment.yaml", "service.yaml", "hpa.yaml", "configmap.yaml", "ingress.yaml", "_helpers.tpl")
        foreach ($template in $requiredTemplates) {
            if (Test-Path "$templatesPath\$template") {
                Write-Host "  [OK] templates\$template" -ForegroundColor Green
            } else {
                Write-Host "  [FAIL] templates\$template - missing!" -ForegroundColor Red
                $missingFiles += "$templatesPath\$template"
            }
        }
    } else {
        Write-Host "  [FAIL] templates/ - directory missing!" -ForegroundColor Red
    }
} else {
    Write-Host "  [FAIL] Helm chart missing!" -ForegroundColor Red
}

# Validate Helm chart
Write-Host "`n4. Validating Helm chart (helm lint)..." -ForegroundColor Yellow
if (Get-Command helm -ErrorAction SilentlyContinue) {
    Push-Location $chartPath
    $lintOutput = helm lint . 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Helm chart is valid" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] Helm chart errors:" -ForegroundColor Yellow
        Write-Host $lintOutput
    }
    Pop-Location
} else {
    Write-Host "  [SKIP] Helm not installed, skipped" -ForegroundColor Gray
}

# Check YAML syntax
Write-Host "`n5. Checking YAML files..." -ForegroundColor Yellow
$yamlFiles = Get-ChildItem -Path . -Include *.yaml,*.yml -Recurse -File | Where-Object { $_.FullName -notmatch "\.terraform" }
foreach ($yamlFile in $yamlFiles) {
    try {
        $content = Get-Content $yamlFile.FullName -Raw -ErrorAction Stop
        if ($content -match '^\s*---' -or $content -match '^[a-zA-Z]') {
            Write-Host "  [OK] $($yamlFile.Name)" -ForegroundColor Green
        }
    } catch {
        Write-Host "  [WARN] $($yamlFile.Name) - possible syntax issues" -ForegroundColor Yellow
    }
}

# Validate Terraform syntax
Write-Host "`n6. Validating Terraform syntax..." -ForegroundColor Yellow
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    $originalBackend = Get-Content "backend.tf" -Raw
    $tempBackend = "terraform {`n  backend `"local`" {}`n}`n"
    Set-Content "backend.tf" -Value $tempBackend -NoNewline
    
    try {
        terraform init -backend=false 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            terraform validate 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [OK] Terraform files are valid" -ForegroundColor Green
            } else {
                Write-Host "  [FAIL] Terraform validation errors" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "  [WARN] Failed to validate Terraform syntax" -ForegroundColor Yellow
    } finally {
        Set-Content "backend.tf" -Value $originalBackend -NoNewline
    }
} else {
    Write-Host "  [SKIP] Terraform not installed, skipped" -ForegroundColor Gray
}

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Green
if ($missingFiles.Count -eq 0) {
    Write-Host "All required files present!" -ForegroundColor Green
} else {
    Write-Host "Missing files:" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "  - $file" -ForegroundColor Red
    }
}

Write-Host "`nValidation completed!" -ForegroundColor Green
