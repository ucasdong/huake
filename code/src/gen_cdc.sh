#/bin/sh
#
# ./gen_cdc $1 $2
#
# example
# test.v
# assign dbg_port[2:0]   = link_up[2:0];
#
# ./gen_cdc test.v dbg_port
# $1 filename
# $2 dbg signal name

filename=`basename -s .v $1`


grep assign ${filename}.v | grep $2 > ${filename}.tmp

# del unuse signal
sed -i 's/assign//g' ${filename}.tmp
sig1=`grep = ${filename}.tmp | awk -F [ '{print $1}' | head -n 1`
sed -i "s/${sig1}//g" ${filename}.tmp

num=`wc -l ${filename}.tmp | awk '{print $1}'`

> ${filename}.tmp2
for(( loop=1; loop<=${num}; loop++)); do
    str=`head -n ${loop} ${filename}.tmp | tail -n 1`
    mult=`echo ${str} | awk -F ] '{print $1}' | grep -c :`

    # mult signal
    if [ ${mult} = "1" ]; then
        line1=`echo ${str} | awk -F ] '{print $1}' | awk -F : '{print $1}' | awk -F [ '{print $2}'`
        line2=`echo ${str} | awk -F ] '{print $1}' | awk -F ] '{print $1}' | awk -F : '{print $2}'`
        line3=`echo ${str} | awk -F ] '{print $2}' | awk -F [ '{print $2}' | awk -F : '{print $1}'`
        line4=`echo ${str} | awk -F ] '{print $2}' | awk -F [ '{print $2}' | awk -F : '{print $2}'`
        sig_name=`echo ${str} | awk -F = '{print $2}' | awk -F [ '{print $1}'`
        sig_num=${line4}

        for(( trig_num=${line2}; trig_num<=${line1}; trig_num++ ));do
            if (("${trig_num}" < "10" )); then
	        trig_num2="000${trig_num}"
            elif (( "${trig_num}" < "100")); then
	        trig_num2="00${trig_num}"
            elif (( "${trig_num}" < "1000" )); then
	        trig_num2="0${trig_num}"
            else
	        trig_num2="${trig_num}"
	    fi
            # all mult signal is 0
            if [ ${sig_name} == "'h0;" ]; then
                echo "<${trig_num2}>=TRIG[${trig_num}]" >> ${filename}.tmp2
            # mult signal
            else
                echo "<${trig_num2}>=${sig_name}[${sig_num}]" >> ${filename}.tmp2
            fi
            sig_num=$((sig_num+1))
         done
   # single signal
    else
        line1=`echo ${str} | awk -F ] '{print $1}' | awk -F [ '{print $2}'`
        sig_name=`echo ${str} | awk -F = '{print $2}' | awk -F \; '{print $1}'`


        if (("${line1}" < "10" )); then
	    trig_num2="000${line1}"
        elif (( "${line1}" < "100")); then
            trig_num2="00${line1}"
        elif (( "${line1}" < "1000" )); then
	    trig_num2="0${line1}"
        else
	    trig_num2="${line1}"
	fi
        # signal is 0
        if [ ${sig_name} == "'h0;" ]; then
             echo "<${trig_num2}>=TRIG[${line1}]" >> ${filename}.tmp2
        # single signal
        else
             echo "<${trig_num2}>=${sig_name}" >> ${filename}.tmp2
        fi
    fi
done

# del space
sed -i "s/ \+//g" ${filename}.tmp2
sed -i "s/^/SignalExport.triggerChannel<0000>/g" ${filename}.tmp2

cdc_num=`wc -l ${filename}.tmp2 | awk '{print $1}'`

head_str="SignalExport.bus<0000>.channelList=0"
for(( loop=1; loop<${cdc_num}; loop++ )); do
    head_str="${head_str} ${loop}"
done

echo "#ChipScope Core Generator Project File Version 3.0"  > ${filename}.cdc
echo "${head_str}"                            >> ${filename}.cdc
echo "SignalExport.bus<0000>.name=TRIG0"      >> ${filename}.cdc
echo "SignalExport.bus<0000>.offset=0.0"      >> ${filename}.cdc
echo "SignalExport.bus<0000>.precision=0"     >> ${filename}.cdc
echo "SignalExport.bus<0000>.radix=Bin"       >> ${filename}.cdc
echo "SignalExport.bus<0000>.scaleFactor=1.0" >> ${filename}.cdc
echo "SignalExport.clockChannel=CLK"          >> ${filename}.cdc
echo "SignalExport.dataEqualsTrigger=true"    >> ${filename}.cdc

cat ${filename}.tmp2 >> ${filename}.cdc

echo "SignalExport.triggerPort<0000>.name=TRIG0"      >> ${filename}.cdc
echo "SignalExport.triggerPortCount=1"                >> ${filename}.cdc
echo "SignalExport.triggerPortIsData<0000>=true"      >> ${filename}.cdc
echo "SignalExport.triggerPortWidth<0000>=${cdc_num}" >> ${filename}.cdc
echo "SignalExport.type=ila"                          >> ${filename}.cdc

rm -rf ${filename}.tmp ${filename}.tmp2
