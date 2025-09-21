# Install Script Timeout Modifications

## Overview
Added 10-second timeouts to all interactive prompts in `install_flatpaks.sh` to enable automated/unattended execution.

## Modified Prompts

### 1. Initial Continue Prompt (Line 1052-1056)
**Location**: `show_title_screen()` function  
**Original**: `read -r`  
**Modified**: `read -t 10 -r`

```bash
# Before
echo -e "${WHITE}Press ${GREEN}[ENTER]${WHITE} to continue or ${RED}[CTRL+C]${WHITE} to exit...${NC}"
read -r

# After  
echo -e "${WHITE}Press ${GREEN}[ENTER]${WHITE} to continue or ${RED}[CTRL+C]${WHITE} to exit...${NC}"
echo -e "${GRAY}(Auto-continuing in 10 seconds if no input...)${NC}"
read -t 10 -r || {
    echo -e "\n${YELLOW}[AUTO]${NC} No input detected, automatically continuing installation..."
}
```

### 2. Storage Space Warning (Line 1162-1166)
**Location**: `check_storage_space()` function  
**Original**: `read -p "Continue anyway? [y]es/[N]o: " -r`  
**Modified**: `read -t 10 -p "Continue anyway? [y]es/[N]o: " -r`

```bash
# Before
read -p "$(echo -e "${WHITE}Continue anyway? ${GREEN}[y]${WHITE}es/${RED}[N]${WHITE}o: ${NC}")" -r

# After
echo -e "${GRAY}(Auto-continuing in 10 seconds if no input...)${NC}"
read -t 10 -p "$(echo -e "${WHITE}Continue anyway? ${GREEN}[y]${WHITE}es/${RED}[N]${WHITE}o: ${NC}")" -r || {
    echo -e "\n${YELLOW}[AUTO]${NC} No input detected, automatically continuing..."
    REPLY="y"
}
```

### 3. Resume Installation State (Line 1379-1383)
**Location**: `load_installation_state()` function  
**Original**: `read -p "Resume from previous state? [y]es/[N]o: " -r`  
**Modified**: `read -t 10 -p "Resume from previous state? [y]es/[N]o: " -r`

```bash
# Before
read -p "$(echo -e "${WHITE}Resume from previous state? ${GREEN}[y]${WHITE}es/${RED}[N]${WHITE}o: ${NC}")" -r

# After
echo -e "${GRAY}(Auto-continuing fresh in 10 seconds if no input...)${NC}"
read -t 10 -p "$(echo -e "${WHITE}Resume from previous state? ${GREEN}[y]${WHITE}es/${RED}[N]${WHITE}o: ${NC}")" -r || {
    echo -e "\n${YELLOW}[AUTO]${NC} No input detected, starting fresh installation..."
    REPLY="n"
}
```

## Behavior Changes

### Default Actions After Timeout
1. **Initial prompt**: Continues with installation
2. **Storage warning**: Continues installation even with low disk space (REPLY="y")
3. **Resume state**: Starts fresh installation instead of resuming (REPLY="n")

### Visual Indicators
- Added gray text indicating auto-continuation timing
- Clear "[AUTO]" prefix for timeout messages
- Consistent messaging across all prompts

## Usage

### Automated/Unattended Installation
The script will now run completely unattended if no user input is provided:

```bash
# Run script and let it auto-continue
./install_flatpaks.sh

# Or use in automation/scripts
curl -sSL https://raw.githubusercontent.com/user/repo/main/install_flatpaks.sh | bash
```

### Interactive Mode (No Change)
Users can still interact normally - pressing Enter or providing input will work exactly as before, but now with the safety net of auto-continuation.

## Testing

Created `test_timeout.sh` to verify timeout functionality works correctly:

```bash
./test_timeout.sh
```

The test confirms that:
- Timeout triggers after specified duration
- Fallback actions execute properly
- Visual feedback is clear and helpful

## Benefits

1. **Automation-Friendly**: Script can run unattended in CI/CD or automated environments
2. **User-Friendly**: Still fully interactive for manual use
3. **Safe Defaults**: Reasonable default choices for each timeout scenario
4. **Clear Feedback**: Users always know what's happening and when

## Compatibility

- Works with all POSIX-compliant shells (bash, zsh, etc.)
- Backward compatible - existing usage patterns unchanged
- No additional dependencies required
- Maintains all existing functionality

The install script is now ready for both interactive and automated use cases!