# ~/.config/nushell/scripts/starship_utils.nu

def get-config-path [] {
    $"($env.HOME)/.config/starship/starship.toml"
}

# AWS Module Toggle 
export def --env toggle-aws [] {
    let path = (get-config-path)
    if ($path | path exists) {
        let config = (open $path)
        # aws module default isabled = false
        let is_disabled = ($config.aws.disabled? | default false)
        
        let new_config = ($config | upsert aws.disabled (not $is_disabled))
        $new_config | save -f $path
        
        let status = (if (not $is_disabled) { "OFF (hidden)" } else { "ON (visible)" })
        print $"AWS module is now ($status)"
    }
}

# GCloud Module Toggle
export def --env toggle-gcloud [] {
    let path = (get-config-path)
    if ($path | path exists) {
        let config = (open $path)
        let is_disabled = ($config.gcloud.disabled? | default false)
        
        let new_config = ($config | upsert gcloud.disabled (not $is_disabled))
        $new_config | save -f $path
        
        let status = (if (not $is_disabled) { "OFF (hidden)" } else { "ON (visible)" })
        print $"GCloud module is now ($status)"
    }
}
