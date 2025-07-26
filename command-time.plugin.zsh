_command_time_preexec() {
  # check excluded
  if [ -n "$ZSH_COMMAND_TIME_EXCLUDE" ]; then
    cmd="$1"
    for exc ($ZSH_COMMAND_TIME_EXCLUDE) do;
      if grep -qF "$exc" <<< "$cmd"; then
        # echo "command excluded: $exc"
        return
      fi
    done
  fi

  _command_time_timer=${timer:-$SECONDS}
  ZSH_COMMAND_TIME_MSG=${ZSH_COMMAND_TIME_MSG-"Time: %s"}
  ZSH_COMMAND_TIME_COLOR=${ZSH_COMMAND_TIME_COLOR-"white"}
  ZSH_COMMAND_TIME_NO_COLOR=${ZSH_COMMAND_TIME_NO_COLOR-""}
  export ZSH_COMMAND_TIME=""
}

_command_time_precmd() {
  local timer_show
  if [ $_command_time_timer ]; then
    timer_show=$(($SECONDS - $_command_time_timer))
    if [ -n "$TTY" ] && [[ $timer_show -ge ${ZSH_COMMAND_TIME_MIN_SECONDS:-3} ]]; then
      export ZSH_COMMAND_TIME="$timer_show"
      if [ ! -z ${ZSH_COMMAND_TIME_MSG} ]; then
        zsh_command_time
      fi
    fi
    unset _command_time_timer
  fi
}

zsh_command_time() {
  local days hours min sec sec_fmt timer_show color
  if [ -n "$ZSH_COMMAND_TIME" ]; then
    # Round to integers
    days=$(( ${ZSH_COMMAND_TIME%.*} / 86400 ))
    hours=$(( ${ZSH_COMMAND_TIME%.*} / 3600 % 24 ))
    min=$(( ${ZSH_COMMAND_TIME%.*} / 60 % 60 ))
    sec=$(( ZSH_COMMAND_TIME % 60 ))
    sec_fmt=$(printf '%d' "$sec")
    color="$ZSH_COMMAND_TIME_COLOR"
    if [[ "$ZSH_COMMAND_TIME" == *.* ]]; then
      # If SECONDS is a float, we limit the precision to 2 decimal places
      sec_fmt=$(printf '%02.2f' "$sec")
    fi
    if [[ "$min" == 0 ]]; then
        color="green"
        timer_show="${sec_fmt}s"
    elif [[ 1 -le "$min" && "$min" -le 3 ]]; then
        color="yellow"
        timer_show="${min}m ${sec_fmt}s"
    else
        if [[ "$days" != 0 ]]; then
            color="red"
            timer_show="${days}d ${hours}h ${min}m ${sec_fmt}s"
        elif [[ "$hours" != 0 ]]; then
            color="red"
            timer_show="${hours}h ${min}m ${sec_fmt}s"
        else
            color="red"
            timer_show="${min}m ${sec_fmt}s"
        fi
    fi
    if [ -n "$ZSH_COMMAND_TIME_NO_COLOR" ]; then
      color="$ZSH_COMMAND_TIME_COLOR"
    fi
    print -P "%F{$ZSH_COMMAND_TIME_COLOR}$(printf "${ZSH_COMMAND_TIME_MSG}" "%F{$color}$timer_show")%f"
  fi
}

precmd_functions+=(_command_time_precmd)
preexec_functions+=(_command_time_preexec)
