# bash completion support for ec2ssh

_ec2ssh() {
    local cmd cur prev subcmd
    cmd=$1
    cur=$2
    prev=$3

    subcmds="help init remove update version"
    common_opts="--dotfile --verbose"

    # contextual completion
    case $prev in
        ec2ssh)
            case "$cur" in
                -*)
                    COMPREPLY=( $(compgen -W "$common_opts" $cur) )
                    ;;
                *)
                    COMPREPLY=( $(compgen -W "$subcmds" $cur) )
            esac
            return 0
            ;;
        --aws-key)
            COMPREPLY=()
            return 0;
            ;;
        --dotfile)
            COMPREPLY=( $(compgen -o default -- "$cur"))
            return 0;
            ;;
    esac

    # complete options
    subcmd=${COMP_WORDS[1]}

    case $subcmd in
        update)
            COMPREPLY=( $(compgen -W "--aws-key $common_opts" -- "$cur") )
            ;;
        help)
            COMPREPLY=( $(compgen -W "$subcmds" $cur) )
            ;;
        *)
            COMPREPLY=( $(compgen -W "$common_opts" -- "$cur") )
            ;;
    esac

    return 0

}

complete -F _ec2ssh ec2ssh
