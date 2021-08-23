import * as cdk from '@aws-cdk/core';
import * as s3 from '@aws-cdk/aws-s3';
import * as sagemaker from '@aws-cdk/aws-sagemaker';
import * as iam from '@aws-cdk/aws-iam'
import {
  readFileSync
} from 'fs';

export class CdkStack extends cdk.Stack {

  constructor(scope: cdk.Construct, id: string, props ? : cdk.StackProps) {
    super(scope, id, props);

    const INSTANCE_TYPE = 'ml.m5.4xlarge'
    const CODE_REPO = 'https://github.com/amliuyong/aws-gcr-qc-life-science-public.git'

    // The code that defines your stack goes here

    // CfnParameter  //////////////////////////

    const instanceTypeParam = new cdk.CfnParameter(this, "NotebookInstanceType", {
      type: "String",
      default: INSTANCE_TYPE,
      description: "Sagemaker notebook instance type"
    });

    // Resouces  //////////////////////////

    const s3bucket = new s3.Bucket(this, 'amazon-braket', {
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      bucketName: `amazon-braket-${this.account}-${this.region}`,
      autoDeleteObjects: true
    });

    const role = this.createNotebookIamRole()

    const onStartContent = readFileSync(`${__dirname}/onStart.template`, 'utf-8')

    const base64Encode = (str: string): string => Buffer.from(str, 'binary').toString('base64');
    const onStartContentBase64 = base64Encode(onStartContent)

    const installBraketSdK = new sagemaker.CfnNotebookInstanceLifecycleConfig(this, 'install-braket-sdk', {
      onStart: [{
        "content": onStartContentBase64
      }]
    });

    const notebookInstnce = new sagemaker.CfnNotebookInstance(this, 'GCRQCLifeScience', {
      instanceType: instanceTypeParam.valueAsString,
      roleArn: role.roleArn,
      rootAccess: 'Enabled',
      lifecycleConfigName: installBraketSdK.attrNotebookInstanceLifecycleConfigName,
      defaultCodeRepository: CODE_REPO,
      volumeSizeInGb: 120,

    });

    // Output //////////////////////////

    new cdk.CfnOutput(this, "notebookName", {
      value: notebookInstnce.attrNotebookInstanceName,
      description: "Notebook name"
    });

    new cdk.CfnOutput(this, "bucketName", {
      value: s3bucket.bucketName,
      description: "S3 bucket name"
    });

    const notebookUrl = `https://console.aws.amazon.com/sagemaker/home?region=${this.region}#/notebook-instances/openNotebook/${notebookInstnce.attrNotebookInstanceName}?view=classic`

    new cdk.CfnOutput(this, "notebookUrl", {
      value: notebookUrl,
      description: "Notebook URL"
    });
  }

  // Methods //////////////////////////

  createNotebookIamRole(): iam.Role {

    const role = new iam.Role(this, 'gcr-qc-notebook-role', {
      assumedBy: new iam.ServicePrincipal('sagemaker.amazonaws.com'),
    });

    role.addManagedPolicy(iam.ManagedPolicy.fromAwsManagedPolicyName('AmazonBraketFullAccess'))
    role.addToPolicy(new iam.PolicyStatement({
      resources: [
        'arn:aws:s3:::gcr-qc-life-science-cdk-*',
        'arn:aws:s3:::amazon-braket-*',
        'arn:aws:s3:::braketnotebookcdk-*'
      ],
      actions: [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
    }));

    role.addToPolicy(new iam.PolicyStatement({
      resources: [
        `arn:aws:logs:*:${this.account}:log-group:/aws/sagemaker/*`
      ],
      actions: [
        "logs:CreateLogStream",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:CreateLogGroup"
      ]
    }));

    role.addToPolicy(new iam.PolicyStatement({
      resources: [
        '*'
      ],
      actions: [
        "braket:*"
      ]
    }));
    return role;
  }
}