#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Parse arguments
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
fi

# Configuration
USERNAME="sebrandon1"
CLONE_BASE_DIR="/Users/bpalm/Repositories/go/src/github.com/openshift-kni"

# List of repos to fork and clone (excluding ones already done)
REPOS=(
    "openshift-kni/numaresources-operator"
    "openshift-kni/oran-o2ims"
    "openshift-kni/lifecycle-agent"
    "openshift-kni/cluster-group-upgrades-operator"
    "openshift-kni/performance-addon-operators"
    "openshift-kni/eapol-operator"
    "openshift-kni/mixed-cpu-node-plugin"
    "openshift-kni/example-cnf"
    "openshift-kni/oran-hwmgr-plugin"
    "openshift-kni/kkube"
)

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}ERROR: GitHub CLI (gh) is not installed${NC}"
    echo ""
    echo "Please install gh:"
    echo "  - macOS: brew install gh"
    echo "  - Linux: https://github.com/cli/cli#installation"
    echo ""
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}ERROR: Not authenticated with GitHub CLI${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

if [ "$DRY_RUN" = true ]; then
    echo -e "${MAGENTA}=== DRY RUN MODE ===${NC}"
    echo -e "${MAGENTA}No changes will be made. This is a preview of what would happen.${NC}"
    echo ""
fi

echo -e "${BLUE}Starting fork and clone process for ${#REPOS[@]} repositories...${NC}"
echo ""

# Create base directory if it doesn't exist
mkdir -p "$CLONE_BASE_DIR"

for repo in "${REPOS[@]}"; do
    repo_name=$(basename "$repo")
    repo_org=$(dirname "$repo")
    clone_path="$CLONE_BASE_DIR/$repo_name"
    
    echo -e "${YELLOW}Processing: $repo${NC}"
    
    # Check if already cloned
    if [ -d "$clone_path" ]; then
        echo -e "  ${BLUE}SKIP${NC}: Already exists at $clone_path"
        echo ""
        continue
    fi
    
    # Check if fork exists
    echo -n "  Checking if fork exists under $USERNAME... "
    if gh repo view "$USERNAME/$repo_name" &> /dev/null; then
        echo -e "${GREEN}YES${NC}"
        FORK_EXISTS=true
    else
        echo -e "${YELLOW}NO${NC}"
        FORK_EXISTS=false
        
        if [ "$DRY_RUN" = true ]; then
            echo -e "  ${MAGENTA}[DRY RUN]${NC} Would create fork of $repo"
        else
            echo -n "  Creating fork... "
            
            # Create fork
            if gh repo fork "$repo" --clone=false &> /dev/null; then
                echo -e "${GREEN}DONE${NC}"
            else
                echo -e "${RED}FAILED${NC}"
                echo -e "  ${RED}ERROR: Could not create fork of $repo${NC}"
                echo ""
                continue
            fi
            
            # Wait a moment for fork to be ready
            sleep 2
        fi
    fi
    
    if [ "$DRY_RUN" = true ]; then
        # Show what would happen in dry run mode
        echo -e "  ${MAGENTA}[DRY RUN]${NC} Would clone fork to: $clone_path"
        echo -e "  ${MAGENTA}[DRY RUN]${NC} Would set up remotes:"
        echo -e "    origin   -> ${USERNAME}/$repo_name (your fork)"
        echo -e "    upstream -> $repo (upstream)"
        echo -e "  ${MAGENTA}[DRY RUN]${NC} Would fetch upstream"
        echo -e "  ${MAGENTA}✓ Would complete${NC}: $repo_name"
        echo ""
        continue
    fi
    
    # Clone the fork
    echo -n "  Cloning fork to $clone_path... "
    if git clone "https://github.com/$USERNAME/$repo_name.git" "$clone_path" &> /dev/null; then
        echo -e "${GREEN}DONE${NC}"
    else
        echo -e "${RED}FAILED${NC}"
        echo -e "  ${RED}ERROR: Could not clone fork${NC}"
        echo ""
        continue
    fi
    
    # Set up remotes
    echo -n "  Setting up remotes... "
    cd "$clone_path"
    
    # Rename origin to origin (it's already your fork)
    # Add upstream remote
    if git remote add upstream "https://github.com/$repo.git" &> /dev/null; then
        echo -e "${GREEN}DONE${NC}"
        echo -e "    origin   -> ${USERNAME}/$repo_name (your fork)"
        echo -e "    upstream -> $repo (upstream)"
    else
        echo -e "${YELLOW}WARNING${NC}: Could not add upstream remote"
    fi
    
    # Fetch upstream
    echo -n "  Fetching upstream... "
    if git fetch upstream &> /dev/null; then
        echo -e "${GREEN}DONE${NC}"
    else
        echo -e "${YELLOW}WARNING${NC}"
    fi
    
    cd - > /dev/null
    
    echo -e "  ${GREEN}✓ Complete${NC}: $repo_name"
    echo ""
done

echo ""
if [ "$DRY_RUN" = true ]; then
    echo -e "${MAGENTA}Dry run complete!${NC}"
    echo ""
    echo -e "${MAGENTA}No changes were made. Run without --dry-run to execute.${NC}"
else
    echo -e "${GREEN}Process complete!${NC}"
fi
echo ""
echo "Summary:"
echo "  Base directory: $CLONE_BASE_DIR"
echo "  Processed: ${#REPOS[@]} repositories"
echo ""
if [ "$DRY_RUN" = false ]; then
    echo "Next steps:"
    echo "  1. cd into any repo: cd $CLONE_BASE_DIR/<repo-name>"
    echo "  2. Create a branch: git checkout -b add-kustomize-validation"
    echo "  3. Copy the test-kustomize.sh and workflow from telco-reference"
    echo "  4. Test locally: make test-kustomize"
    echo "  5. Push and create PR: git push origin add-kustomize-validation"
else
    echo "To execute:"
    echo "  Run without --dry-run flag: ./hack/fork-and-clone-repos.sh"
fi

