#!/bin/bash

# Script generates new testable classes with changed CoreBluetooth references to mock references.
# New testable classes are prefixed with "_"

RED='\033[0;31m'
NC='\033[0m'

hash gsed &> /dev/null
if [ $? -eq 1 ]; then
    echo -e "${RED}Could not found gsed command!${NC}"
    echo "Install it with command: brew install gnu-sed"
    exit 1
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "${DIR}"

# added import RxBluetoothKit to classes
importblekit_pattern="s/import CoreBluetooth/&\n@testable import RxBluetoothKit/g"
# change all occurance of CoreBluetooth classes to mock classes (e.g. CBPeripheral to CBPeripheralMock)
mock_pattern="s/\b(CBPeripheral|CBCentralManager|CBService|CBCharacteristic|CBDescriptor|CBL2CAPChannel|CBPeer)\b/&Mock/g"
# change all occurance of RxBluetoothKit classes in testable classes (e.g. change Peripheral to _Peripheral)
testable_pattern="s/\b(Peripheral|BluetoothManager|Service|Characteristic|Descriptor|BluetoothError|CBPeripheralDelegateWrapper|CBCentralManagerDelegateWrapper|CBPeripheralDelegate|CBCentralManagerDelegate|ScannedPeripheral|ScanOperation|RestoredState)\b/_&/g"
# remove all public's
removepublic_pattern="s/\bpublic \b//g"

create_testable_file () {
	class_name=$1	
	in_file_path="../Source/$1.swift"
	testable_class_name="_$class_name"
	out_file_path="../Tests/Autogenerated/$testable_class_name.generated.swift"
	class_pattern="s/class $class_name/class $testable_class_name/g"
	gsed -r "$importblekit_pattern;$testable_pattern;$class_pattern;$mock_pattern;$testable_pattern;$removepublic_pattern" $in_file_path > $out_file_path
}

create_testable_file BluetoothManager
create_testable_file Peripheral
create_testable_file Service
create_testable_file Characteristic
create_testable_file Descriptor
create_testable_file BluetoothError
create_testable_file CBPeripheralDelegateWrapper
create_testable_file CBCentralManagerDelegateWrapper
create_testable_file ScannedPeripheral
create_testable_file ScanOperation
create_testable_file RestoredState

