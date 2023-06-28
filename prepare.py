import subprocess
import urllib.request

def handler(event, context):
    

    url = "https://huggingface.co/orel12/ggml-gpt4all-j-v1.3-groovy/resolve/main/ggml-gpt4all-j-v1.3-groovy.bin"  
    filename = "/tmp/ggml-gpt4all-j-v1.3-groovy.bin"  
    try:

        # process = subprocess.Popen("pip install chromadb sentence_transformers", stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        # # Read the output from the subprocess
        # stdout, stderr = process.communicate()

        urllib.request.urlretrieve(url, filename)
        print("File downloaded successfully.")


    except urllib.error.URLError as e:
        print("Error occurred while downloading the file:", e)


