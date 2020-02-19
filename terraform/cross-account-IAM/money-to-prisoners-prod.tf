# generated by https://github.com/ministryofjustice/money-to-prisoners-deploy
# IAM roles and policies used by Prisoner Money team's money-to-prisoners-prod namespace

data "aws_iam_policy_document" "money-to-prisoners-prod-kiam-trust-chain" {
  # KIAM trust chain to allow pods to assume roles defined below
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_role.nodes.arn]
    }
    actions = ["sts:AssumeRole"]
  }
}

variable "money-to-prisoners-prod-tags" {
  type = map(string)
  default = {
    business-unit          = "HMPPS"
    application            = "money-to-prisoners"
    is-production          = "true"
    environment-name       = "prod"
    owner                  = "prisoner-money"
    infrastructure-support = "platforms@digital.justice.gov.uk"
  }
}

resource "aws_iam_role" "money-to-prisoners-prod-api" {
  name               = "money-to-prisoners-prod-iam-role-api"
  description        = "IAM role for api pods in money-to-prisoners-prod"
  tags               = var.money-to-prisoners-prod-tags
  assume_role_policy = data.aws_iam_policy_document.money-to-prisoners-prod-kiam-trust-chain.json
}

resource "kubernetes_secret" "money-to-prisoners-prod-api" {
  metadata {
    name      = "iam-role-api"
    namespace = "money-to-prisoners-prod"
  }

  data = {
    arn       = aws_iam_role.money-to-prisoners-prod-api.arn
    name      = aws_iam_role.money-to-prisoners-prod-api.name
    unique_id = aws_iam_role.money-to-prisoners-prod-api.unique_id
  }
}

data "aws_iam_policy_document" "money-to-prisoners-prod-api" {
  # "api" policy statements for "money-to-prisoners-prod" namespace

  # allow pods to assume this role
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.money-to-prisoners-prod-api.arn]
  }

  # allows direct access to "landing" S3 bucket for Prison Network App in mojap AWS account
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      "arn:aws:s3:::mojap-land/hmpps/prisoner-money/*",
    ]
  }
}

resource "aws_iam_policy" "money-to-prisoners-prod-api" {
  name   = "money-to-prisoners-prod-iam-policy-api"
  policy = data.aws_iam_policy_document.money-to-prisoners-prod-api.json
}

resource "aws_iam_role_policy_attachment" "money-to-prisoners-prod-api" {
  role       = aws_iam_role.money-to-prisoners-prod-api.name
  policy_arn = aws_iam_policy.money-to-prisoners-prod-api.arn
}