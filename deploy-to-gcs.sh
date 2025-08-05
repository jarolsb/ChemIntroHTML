#!/bin/bash

# Google Cloud Storage Deployment Script for Chemistry Adventure
# Make sure you have Google Cloud SDK installed and authenticated

# Configuration
BUCKET_NAME="your-bucket-name-here"  # Replace with your actual bucket name
PROJECT_ID="your-project-id"         # Replace with your GCP project ID

echo "🚀 Deploying Chemistry Adventure to Google Cloud Storage..."

# Check if gsutil is installed
if ! command -v gsutil &> /dev/null; then
    echo "❌ Error: gsutil is not installed. Please install Google Cloud SDK first."
    echo "Visit: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if bucket exists, create if not
if ! gsutil ls -b gs://${BUCKET_NAME} &> /dev/null; then
    echo "📦 Creating bucket gs://${BUCKET_NAME}..."
    gsutil mb -p ${PROJECT_ID} gs://${BUCKET_NAME}
fi

# Upload all files
echo "📤 Uploading files..."
gsutil -m cp *.html gs://${BUCKET_NAME}/
gsutil cp styles.css gs://${BUCKET_NAME}/

# Set website configuration
echo "⚙️ Configuring website..."
echo '{
  "mainPageSuffix": "index.html",
  "notFoundPage": "404.html"
}' > website-config.json
gsutil web set -m index.html gs://${BUCKET_NAME}
rm website-config.json

# Make files public
echo "🌐 Making files public..."
gsutil iam ch allUsers:objectViewer gs://${BUCKET_NAME}

# Set cache control for better performance
echo "⚡ Setting cache headers..."
gsutil -m setmeta -h "Cache-Control:public, max-age=3600" gs://${BUCKET_NAME}/*.html
gsutil setmeta -h "Cache-Control:public, max-age=86400" gs://${BUCKET_NAME}/*.css

echo "✅ Deployment complete!"
echo "🌐 Your site is available at:"
echo "   https://storage.googleapis.com/${BUCKET_NAME}/index.html"
echo ""
echo "💡 Tip: For a custom domain, consider using Cloud CDN or Firebase Hosting"