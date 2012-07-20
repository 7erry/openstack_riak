#!/bin/bash
#Copyright 2012 Terry Walters
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

options_found=0

while getopts ":i:g:k:t:n:" opt; do
  options_found=1
  case $opt in
    i)
			aminame=$OPTARG
      ;;
    g)
			secgroup="$OPTARG"      
			;;
    k)
			seckey="$OPTARG"      
			;;
    t)
			amitype="$OPTARG"
      ;;
    n)
			instances="$OPTARG"
      ;;
    \?)
			options_found=0
      ;;
    :)
      echo "Option -$OPTARG requires arguments. retry with -?" >&2
      exit 1
      ;;
  esac
done

if ((!options_found)); then
			echo "Ensure you have setup euca2ools -> http://www.eucalyptus.com/ and source your RC file"
      echo "Usage "
      echo "      -t (type)"
      echo "      -g (security group)"
      echo "      -k (key)"
      echo "      -i (AMI to instantiate)"
      echo "      -n (Number of instances)"
      echo " "
      echo "example: $0 -i ami-00000021 -g nimbus -k apifoundry-dev-ewr1 -t m1.small"
			exit 1
fi

euca-run-instances $aminame -g $secgroup -k $seckey -f ./riak_master.sh -t $amitype -n $instances >node_instances.txt
cat node_instances.txt



