import functions_framework
import google.generativeai as genai
import json
import os
import re

# Configure Gemini API key
def configure_genai():
    api_key = os.environ.get('GEMINI_API_KEY')
    if not api_key:
        raise ValueError("GEMINI_API_KEY environment variable is not set")
    genai.configure(api_key=api_key)

@functions_framework.http
def analyze_essay(request):
    """HTTP Cloud Function to analyze a student essay."""
    # Set CORS headers for preflight requests
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)

    # Set CORS headers for the main request
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
    }

    # Check if request is JSON
    if not request.content_type or 'application/json' not in request.content_type.lower():
        return json.dumps({'error': 'Request must be JSON'}), 400, headers

    try:
        # Configure GenAI
        configure_genai()

        request_json = request.get_json(silent=True)
        if not request_json:
            return json.dumps({'error': 'Invalid JSON or empty request body'}), 400, headers

        if 'essay' not in request_json:
            return json.dumps({'error': 'Missing "essay" in request body'}), 400, headers

        essay_text = request_json['essay']
        rubric_criteria = ["Grammar", "Clarity", "Content Relevance", "Structure"] # Predefined criteria

        prompt = f"""
        Analyze the following student essay based on the criteria: {', '.join(rubric_criteria)}.

        Essay:
        {essay_text}

        Provide:
        - An overall score/grade using one of these values: Excellent, Good, Needs Improvement.
        - Concise, actionable feedback for each of the following criteria:
          - Grammar
          - Clarity
          - Content Relevance
          - Structure

        Format your response as a valid JSON object with the following structure:
        {{
          "overallScore": "...",
          "feedback": {{
            "Grammar": "...",
            "Clarity": "...",
            "Content Relevance": "...",
            "Structure": "..."
          }}
        }}
        """

        model_name = "gemini-1.5-flash"
 # Or another suitable model
        model = genai.GenerativeModel(model_name)
        response = model.generate_content(prompt)

        if not response or not response.text:
            return json.dumps({'error': 'Error generating feedback from Gemini API'}), 500, headers

        # Clean up the response to extract valid JSON
        json_string = response.text.strip()
        if json_string.startswith("```json"):
            json_string = json_string[len("```json"):].strip()
        if json_string.endswith("```"):
            json_string = json_string[:-len("```")].strip()
        if json_string.startswith("`"):
            json_string = json_string[1:].strip()
        if json_string.endswith("`"):
            json_string = json_string[:-1].strip()

        try:
            feedback_data = json.loads(json_string)
            return json.dumps(feedback_data), 200, headers
        except json.JSONDecodeError as e:
            # If parsing still fails, return the cleaned response and the error for debugging
            return json.dumps({'cleaned_response': json_string, 'error': f'Could not parse cleaned Gemini response as JSON: {str(e)}'}), 500, headers

    except ValueError as e:
        return json.dumps({'error': str(e)}), 500, headers
    except Exception as e:
        import traceback
        return json.dumps({
            'error': 'Internal server error',
            'details': str(e),
            'traceback': traceback.format_exc()
        }), 500, headers
