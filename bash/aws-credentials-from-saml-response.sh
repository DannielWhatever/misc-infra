#!/bin/bash
ACCOUNT=${1:-1234567890}
ROLE=${2:-"DefaultRole"}
SAML_PROVIDER=MySAML
REGION=us-east-1

echo "Assuming role ${ROLE} in Account ${ACCOUNT}"
echo ""

aws sts assume-role-with-saml --role-arn arn:aws:iam::$ACCOUNT:role/$ROLE --principal-arn arn:aws:iam::$ACCOUNT:saml-provider/$SAML_PROVIDER --saml-assertion file://samlresponse.log --output json | awk -F": "  '
                /AccessKeyId/{ print "export AWS_ACCESS_KEY_ID="$2 }
                /SecretAccessKey/{ print "export AWS_SECRET_ACCESS_KEY="$2 }
                /SessionToken/{ print "export AWS_SESSION_TOKEN="$2 }
'| sed -e 's/",/"/g'

echo ""
echo "export AWS_DEFAULT_REGION=${REGION}

