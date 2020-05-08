+++
date = "2020-05-05"
title = "Hosting Hugo on AWS"
author = "Matthew Edge"
description = "Hugo, CloudFront, and AWS S3"
tags = ["aws", "cloudfront", "s3", "hugo"]
+++

After spending the majority of today trying to figure this out, I'd like to discuss how this
very Hugo blog is hosted on AWS with CloudFront and S3, because it was a monstrosity to get
to thanks to S3.

> **TL;DR**: Add the **uglyurls = true** configuration key in your **config.toml**. That changes the URLs rendered to the ugly form: **baseUrl/posts/homelab.html**. These are well liked by S3 website hosting buckets.

## S3 and CloudFront - with SSL!

We start with a pretty standard S3 Website bucket template. I'm still using CloudFormation YAML
because this is a template I start with for many applications. I'll convert to CDK later..._cough_

It starts with a Bucket and Bucket Policy:

```yaml
Resources:

  WebsiteBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Ref SiteUrl
      VersioningConfiguration:
        Status: Suspended
      WebsiteConfiguration:
        IndexDocument: index.html
        ErrorDocument: index.html
      Tags:
        - Key: app
          Value: !Ref SiteUrl

  WebsiteBucketPolicy:
    Type: AWS::S3::BucketPolicy
    Properties:
      Bucket: !Ref WebsiteBucket
      PolicyDocument:
        Statement:
          - Effect: Allow
            Action:
              - s3:GetObject
            Resource: !Sub "arn:aws:s3:::${WebsiteBucket}/*"
            Principal:
              AWS:
                - !Sub "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${CloudFrontOriginAccessIdentity}"
```

We're creating a Bucket named after our SiteUrl (**blog.medgelabs.io** in this case) and attaching
a bucket policy which limits GetObject access to CloudFront. This ensures traffic flows through
CloudFront and is blocked if someone tries to access the bucket directly. I'm told this is a
good thing.

For the CloudFront distribution:

```yaml
CloudFrontOriginAccessIdentity:
  Type: AWS::CloudFront::CloudFrontOriginAccessIdentity
  Properties:
    CloudFrontOriginAccessIdentityConfig:
      Comment: !Ref SiteUrl

CloudFrontWebsite:
  Type: AWS::CloudFront::Distribution
  Properties:
    DistributionConfig:
      Aliases:
        - !Ref SiteUrl
      Origins:
        - DomainName: !GetAtt WebsiteBucket.RegionalDomainName
          Id: !Ref WebsiteBucket
          S3OriginConfig:
            OriginAccessIdentity: !Sub origin-access-identity/cloudfront/${CloudFrontOriginAccessIdentity}
      Enabled: true
      HttpVersion: http2
      Comment: !Ref SiteUrl
      DefaultRootObject: index.html
      DefaultCacheBehavior:
        AllowedMethods:
          - GET
          - HEAD
        Compress: true
        ForwardedValues:
          QueryString: false
          Cookies:
            Forward: none
        DefaultTTL: 300
        MaxTTL: 1800
        MinTTL: 0
        TargetOriginId: !Ref WebsiteBucket
        ViewerProtocolPolicy: redirect-to-https
      PriceClass: PriceClass_100
      ViewerCertificate:
        AcmCertificateArn: !Ref SslCertArn
        SslSupportMethod: sni-only
        MinimumProtocolVersion: TLSv1.2_2018
    Tags:
      - Key: app
        Value: !Ref SiteUrl
```

There's actually nothing too exotic here, despite the amount of YAML. We have the distribution
pointing to our S3 Website using an Origin Access Identity. That's fancy talk for CloudFront's
keys into my S3 bucket. We also configure SSL with an ACM Certificate. AWS made those free
not too long ago to help support the encrypted web.

Today I learned that the **SslSupportMethod: sni-only** is actually very important. Not using
sni-only can cost you [hundreds of $$ a month](https://aws.amazon.com/cloudfront/pricing/#Request_Pricing_for_All_HTTP_Methods_(per_10,000)).
So don't change that!

Finally, we make a Route53 alias record to use for our vanity URL. **blog.medgelabs.io** in
my case.

```yaml
Route53RecordSetWithCloudFront:
  Type: AWS::Route53::RecordSet
  Properties:
    Name: !Ref SiteUrl
    Type: A
    HostedZoneId: !Ref HostedZoneId
    AliasTarget:
      DNSName: !GetAtt CloudFrontWebsite.DomainName
      HostedZoneId: Z2FDTNDATAQYW2  # Cloudfront Hosted Zone ID
      EvaluateTargetHealth: false
```

Side note: That **HostedZoneId** under **AliasTarget** is hard coded because that's CloudFront's
HostedZoneId. Don't be a dingus like me and point that to your own HostedZoneId. The stack will
fail to create.

Run these templates through CloudFormation and you're all ready to go!
Just run **hugo** in your blog directory, **aws s3 sync ./public s3://your-bucket-here** and navigate to your blog. The front page should be up!

Happy dances commence....until you click on a post link and see the dreaded Access Denied message:

```xml
<Error>
  <Code>AccessDenied</Code>
  <Message>Access Denied</Message>
  <RequestId>B90223BB7C796994</RequestId>
  <HostId>
    REDACTED
  </HostId>
</Error>
```

What? Why?? Why is the homepage good but not the posts?

## Pretty URLs

It's because, by default, Hugo formats URLs in a pretty format. i.e if you have the
standard directory format [Hugo recommends](https://gohugo.io/content-management/organization/):

```
content/
  -- posts/
    -- homelab.md
```

Hugo will render that URL as **baseUrl/posts/homelab/**. In your public folder you'll actually
see that folder and a single **index.html** page with that post's content. S3 doesn't like that.
It doesn't like people accessing folders. It wants you to access files directly. i.e it wants
Hugo to render URLs like **baseUrl/posts/homelab/index.html**. Why? I don't wish I knew.

## Ugly URLs to the Rescue

I poured through blogs and articles on S3 routing, permissions, CloudFront hacks to make the
pretty URLs work, and nothing got rid of that pesky Access Denied error.

Until I stumbled on this page of the Hugo docs: https://gohugo.io/content-management/urls/

Hugo has an **uglyurls** configuration key you can put in your **config.toml** that
changes the URLs rendered to the ugly form: **baseUrl/posts/homelab.html**.

_That's it_. With ugly URLs S3 (and, therefore, CloudFront) is happy and the blog renders.

...Gotta love infrastructure quirks...

Hope this helped! Thanks for coming by the Lab!

