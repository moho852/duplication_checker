#!/bin/bash

# 실행과정 1. 폴더 안에 있는 file 순회
# 	   2. redis queue lpush를 이용해 키가 동일한 데이터를 함께 저장
# 	   3. 전체 redis key를 순회
# 	   4. 각 key에 몇건의 데이터 가 있는지 데이터 수 조회(LLEN)
# 	   5. 데이터가 2건 이상이면 중복으로 가정
# 	   6. 중복 데이터가 있는 데이터의 key의 값을 출력


redis-cli flushall #redis cli 초기화
for file in $(ls)  #현재 file를 for문으로 순회
do	
	key=$(sha256sum $file | awk '{print $1}') #sha256 hasp key를 key 변수에 저장
	redis-cli LPUSH "$key" "$file"		  #redis queue에file 을 저장
done

for key in $(redis-cli keys "*" | awk '{print $1}') #redis 전체 key 조회
do
	len=$(redis-cli LLEN $key)		  # key에 몇건의 데이터가 있는지 LLEN 명령어를 이용해   저장
	if [ $len -gt 1 ] 			  # 만약 2건 이상이라면 (중복되는 데이터가 있다면)
	then	
		echo ======================================
		echo "          중복데이터리스트          "
		redis-cli LRANGE "$key" 0 -1 | awk '{print $1}' # key의 value를 출력
		echo ======================================
	fi
done
