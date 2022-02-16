#!/bin/bash

script_path=$(realpath "$(dirname "$0")")
root_tests_dir=${script_path}/integration_test
integration_tests=$(find ${root_tests_dir} | grep "_test.dart") 
integration_tests_log=/tmp/integration-test-log.txt

fail_status=0

run_integration_test() {
  flutter drive --driver=${script_path}/test_driver/integration_test.dart --target=${1}
}

get_test_path() {
  IFS='/' read -r -a array <<< "${1}"
  point=false
  result=""
  
  for element in "${array[@]}"
  do
    if [[ ${point} == true ]]; then
      result+=/${element}
    elif [[ ${element} == integration_test ]]; then
      point=true
    fi
  done
  if [[ ${point} == false ]]; then
    echo ${1}
  else
    echo ${result}
  fi
}

check_if_test_exists() {
  exists=false
  for integration_test in ${integration_tests}; do
    test=$(get_test_path ${integration_test})
    parsed_test=$(get_test_path ${1})
    if [[ ${parsed_test} == ${test} ]]; then
      exists=true
      break
    else
      continue
    fi
  done
  echo ${exists}
}

run_only_one_test() {
  for integration_test in ${integration_tests}; do
    test=$(get_test_path ${integration_test})
    parsed_test=$(get_test_path ${1})
    if [[ ${parsed_test} == ${test} ]]; then
      run_integration_test ${integration_test}
      break
    else
      continue
    fi
  done
}

get_list_of_tests() {
  for integration_test in ${integration_tests}; do
    echo $(get_test_path ${integration_test})
  done
}

run_all_tests() {
  from=${1}
  from_running=false
  for integration_test in ${integration_tests}; do
    if [[ -n ${from} && ${from_running} == false ]]; then
      test=$(get_test_path ${integration_test})
      from_test=$(get_test_path ${from})
      if [[ ${test} == ${from_test} ]]; then
        from_running=true
      else
        continue
      fi
    fi

    point=0
    p=false
    clear
    echo ""
    echo "Running integration tests:"
  
    for it in ${integration_tests}; do
      if [[ ${integration_test} == ${it} ]]; then
        point=0
        p=true
      elif [[ ${p} == false ]]; then
        point=1
      elif [[ ${p} == true ]]; then
        point=2
      fi
  
      test=$(get_test_path ${it})
      if [[ ${point} == 0 ]]; then
        echo "  [.] ${test}"
      elif [[ ${point} == 1 ]]; then
        echo "  [✔] ${test}"
      elif [[ ${point} == 2 ]]; then
        echo "  [ ] ${test}"
      fi
    done
  
    run_integration_test ${integration_test} > ${integration_tests_log}
    fail_status=$?
    sleep 1
  
    if [[ ${fail_status} != 0 ]]; then
      cat ${integration_tests_log}
      echo ""
      echo "Test: $(get_test_path ${integration_test}) failed."
      exit 1
    fi
  done
  
  clear
  echo ""
  echo "Running integration tests:"

  for it in ${integration_tests}; do
    test=$(get_test_path ${it})
    echo "  [✔] ${test}"
  done
  
  echo ""
  echo "All tests are done."
}

show_help() {
  echo ""
  echo "All possible arguments:"
  echo "  --only <test>    Run only one test"
  echo "  --from <test>    Continue run tests from this test"
  echo "  --list           Show list of all possible tests"
  echo "  --help           Show this help info"
}


if [[ -n "${TESTS_DIR}" ]]; then
  tests_dir=${root_tests_dir}$(get_test_path ${TESTS_DIR})
  if [[ -d "${tests_dir}" ]]; then
    integration_tests=$(find ${tests_dir} | grep "_test.dart") 
  else
    echo "Directory: \"${2}\" doesn't exists."
    exit 1
  fi
fi


if [[ ${#} == 0 ]]; then
  cd ${script_path}
  flutter test
  if [[ $? == 0 ]]; then
    run_all_tests
  fi
elif [[ ${#} == 2 ]]; then
  if [[ ${1} == --only ]]; then
    test_exists=$(check_if_test_exists ${2})
    if [[ ${test_exists} == true ]]; then
      run_only_one_test ${2}
    else
      echo "Test: \"${2}\" doesn't exists."
    fi
  elif [[ ${1} == --from ]]; then
    test_exists=$(check_if_test_exists ${2})
    if [[ ${test_exists} == true ]]; then
      run_all_tests ${2}
    else
      echo "Test: \"${2}\" doesn't exists."
    fi
  else
    echo "Invalid arguments"
    show_help
  fi
elif [[ ${#} == 1 ]]; then
  if [[ ${1} == help || ${1} == --help ]]; then
    show_help
  elif [[ ${1} == ls || ${1} == list || ${1} == --list ]]; then
    get_list_of_tests
  fi
else
  echo "Invalid arguments"
  show_help
fi
