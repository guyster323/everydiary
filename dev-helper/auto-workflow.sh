#!/bin/bash

# 1. 코드 변경사항 분석
cursor-agent -p "Analyze current changes and determine if they're ready for review"

# 2. 자동 커밋 및 푸시
cursor-agent -p "/commit-and-push"

# 3. PR 생성
cursor-agent -p "/create-pr"

# 4. 자동 리뷰 요청
curl -X POST "https://api.github.com/repos/$GITHUB_REPO/pulls/$PR_NUMBER/requested_reviewers" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -d '{"reviewers": ["cursor-bot"]}'

# 5. 퍼플렉시티를 통한 추가 연구
cursor-agent -p "/research-improve based on current PR context"
