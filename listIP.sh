cat node_instances.txt | grep INSTANCE | awk '{print $2}' > node_instance_ids.txt
for record in $(cat node_instance_ids.txt); 
do
euca-describe-instances $record | grep INSTANCE | awk '{print $5}'
done
