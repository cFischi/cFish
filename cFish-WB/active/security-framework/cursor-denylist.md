# Comprehensive Command Denylist for Cursor AI

## Overview
This document provides a comprehensive list of commands that should be denied execution by Cursor AI to ensure system security and prevent potential issues. These commands should be added to the YOLO mode denylist in Cursor settings.

## Dangerous System Commands

### File System Operations
```
rm -rf *
rm -rf /
rm -rf ~
rmdir /s /q
rd /s /q
deltree
format
fdisk
mkfs
```

### Process Management
```
kill -9 1
killall
pkill
taskkill /f /im
```

### User Management
```
userdel
useradd
usermod
passwd
chsh
net user
```

### Network Configuration
```
ifconfig
ip link
route
iptables
netsh
```

### Software Installation/Removal
```
apt remove
apt-get remove
apt purge
apt-get purge
yum remove
dnf remove
pacman -R
brew uninstall
npm uninstall -g
pip uninstall -y
gem uninstall -a
```

## Potentially Risky Web Tools

### Tunneling & Remote Access
```
ngrok
localtunnel
ssh -R
cloudflared
expose
pagekite
webhookrelay
```

### Network Scanning
```
nmap
masscan
zenmap
angry ip scanner
```

### Web Vulnerability Testing
```
sqlmap
nikto
burpsuite
owasp zap
metasploit
```

## Code Execution & Evaluation

### Shell Access
```
bash -i
sh -i
powershell -ep bypass
cmd /c
python -c "import os; os.system('
exec
eval
```

### Database Operations
```
DROP DATABASE
DROP TABLE
TRUNCATE TABLE
DELETE FROM
```

## WordPress-Specific Risks

### Database Operations
```
wp db drop
wp db reset
wp search-replace --all-tables
```

### Plugin/Theme Management
```
wp plugin delete
wp plugin deactivate --all
wp theme delete
wp core update-db
```

### User Management
```
wp user delete
wp user remove-role
wp role delete
```

### Content Operations
```
wp post delete --all
wp comment delete --all
wp term delete
```

## YOLO Mode Configuration

### Configuration Steps
1. Open Cursor settings
2. Navigate to YOLO mode settings
3. Add these commands to the denylist
4. Save settings

### Deny Pattern Example
```
# Basic system commands
rm -rf*
format*
fdisk*

# Network tools
ngrok*
nmap*

# Dangerous code execution
eval*
exec*

# WordPress database operations
wp db*
wp search-replace*

# WordPress destructive commands
wp plugin delete*
wp theme delete*
wp user delete*
wp post delete --all*
```

## Exceptions and Allowed Commands

While the above commands are generally risky, there may be legitimate uses in controlled environments. For specific projects that absolutely require these commands, consider:

1. Creating a separate YOLO mode profile with limited permissions
2. Implementing a confirmation step before execution
3. Using a sandbox environment
4. Creating safer wrapper scripts with validation

### Example of Safe Wrapper Script
```bash
#!/bin/bash
# safe-plugin-delete.sh
# A safer wrapper for 'wp plugin delete' with validation

PLUGIN=$1

if [ -z "$PLUGIN" ]; then
  echo "Error: No plugin specified"
  exit 1
fi

if [[ "$PLUGIN" == "all" || "$PLUGIN" == "--all" ]]; then
  echo "Error: Cannot delete all plugins"
  exit 1
fi

# Check if it's a core or essential plugin
ESSENTIAL_PLUGINS=("woocommerce" "wordpress-seo" "wordfence" "contact-form-7")
for essential in "${ESSENTIAL_PLUGINS[@]}"; do
  if [ "$PLUGIN" == "$essential" ]; then
    echo "Error: Cannot delete essential plugin: $PLUGIN"
    exit 1
  fi
done

# Proceed with deletion
echo "Deleting plugin: $PLUGIN"
wp plugin delete "$PLUGIN"
```

## Monitoring and Auditing

In addition to denying risky commands, implement:

1. Command execution logging
2. Regular audit of all commands run by AI
3. Alerts for attempted execution of denied commands
4. Post-execution verification of system integrity

## Best Practices

1. **Principle of Least Privilege**: Only grant permissions that are absolutely necessary
2. **Regular Updates**: Review and update this denylist regularly
3. **Environment Separation**: Use different permission profiles for development, staging, and production
4. **Team Education**: Ensure all team members understand why these restrictions exist
5. **Regular Backups**: Always maintain regular backups regardless of safeguards

## Additional Security Measures

Beyond command denial, also consider:

1. File integrity monitoring
2. Version control for all changes
3. Regular security scanning
4. User role restrictions
5. Network isolation for sensitive operations

_Created 05-06-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 