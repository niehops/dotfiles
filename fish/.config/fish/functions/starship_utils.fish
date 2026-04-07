# ~/.config/fish/functions/starship_utils.fish

function get_config_path
    echo "$HOME/.config/starship/starship.toml"
end

function toggle-aws
    set -l path (get_config_path)
    if test -f $path
        # Current status ကို yq နဲ့ ဖတ်မယ် (မရှိရင် false လို့ ယူမယ်)
        set -l current (yq '.aws.disabled // false' $path)

        if test "$current" = false
            yq -i '.aws.disabled = true' $path
            echo "AWS module is now OFF (hidden)"
        else
            yq -i '.aws.disabled = false' $path
            echo "AWS module is now ON (visible)"
        end
    end
end

function toggle-gcloud
    set -l path (get_config_path)
    if test -f $path
        set -l current (yq '.gcloud.disabled // false' $path)

        if test "$current" = false
            yq -i '.gcloud.disabled = true' $path
            echo "GCloud module is now OFF (hidden)"
        else
            yq -i '.gcloud.disabled = false' $path
            echo "GCloud module is now ON (visible)"
        end
    end
end
