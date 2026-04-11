# ~/.config/zsh/toggles.zsh

# --- Default Hidden Settings ---
export CLOUDSDK_CONFIG=/tmp/empty-gcloud-config
export GCP_SYMBOL=""
export _AWS_VISIBLE="false"

# --- GCloud Toggle ---
toggle-gcloud() {
    if [[ "$GCP_SYMBOL" == "" ]]; then
        unset CLOUDSDK_CONFIG
        export GCP_SYMBOL=" "
        echo "GCloud Module: [SHOWN]"
    else
        export CLOUDSDK_CONFIG=/tmp/empty-gcloud-config
        export GCP_SYMBOL=""
        echo "GCloud Module: [HIDDEN]"
    fi
}

# --- AWS Toggle ---
toggle-aws() {
    if [[ "$_AWS_VISIBLE" == "false" ]]; then
        if (( ${+_OLD_AWS_PROFILE} )); then
            export AWS_PROFILE=$_OLD_AWS_PROFILE
            unset _OLD_AWS_PROFILE
        fi
        export _AWS_VISIBLE="true"
        echo "AWS Module: [SHOWN]"
    else
        if (( ${+AWS_PROFILE} )); then
            export _OLD_AWS_PROFILE=$AWS_PROFILE
            unset AWS_PROFILE
        fi
        export _AWS_VISIBLE="false"
        echo "AWS Module: [HIDDEN]"
    fi
}
