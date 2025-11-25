import functions_framework
import google.generativeai as genai
import json
import os

# Configure Gemini API key
def configure_genai():
    api_key = os.environ.get('GEMINI_API_KEY')
    if not api_key:
        raise ValueError("GEMINI_API_KEY environment variable is not set")
    genai.configure(api_key=api_key)

@functions_framework.http
def generate_lesson_plan(request):
    """HTTP Cloud Function to generate a lesson plan."""
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
        
        # Get the request data
        request_json = request.get_json(silent=True)
        if not request_json:
            return json.dumps({'error': 'Invalid JSON or empty request body'}), 400, headers
        
        if 'topic' not in request_json or 'gradeLevel' not in request_json:
            return json.dumps({'error': 'Invalid input. Must provide topic and gradeLevel.'}), 400, headers
        
        topic = request_json['topic']
        grade_level = request_json['gradeLevel']
        
        # Generate prompt for Gemini
        prompt = f"""
        Generate a lesson plan for {topic} at a {grade_level} level.
        Include:
        - 2-3 Objectives
        - 3-4 Key Concepts (bullet points)
        - A brief teaching strategy
        - 2 suggested activities.
        Format your response as a valid JSON object with the following structure:
        {{
          "topic": "{topic}",
          "gradeLevel": "{grade_level}",
          "objectives": ["objective1", "objective2"],
          "keyConcepts": ["concept1", "concept2", "concept3"],
          "teachingStrategy": "description here",
          "activities": ["activity1", "activity2"]
        }}
        """
        
        # Use one of the current models - preferring gemini-1.5-flash as suggested in the error
        model_name = "gemini-1.5-flash"

        
        # Generate lesson plan using Gemini
        model = genai.GenerativeModel(model_name)
        response = model.generate_content(prompt)
        
        # Process the response
        if not response:
            return json.dumps({'error': 'Empty response from Gemini API'}), 500, headers
        
        response_text = response.text
        
        # Try to parse as JSON - if Gemini returns properly formatted JSON
        try:
            # Check if response_text is valid JSON
            lesson_plan = json.loads(response_text)
            return json.dumps(lesson_plan), 200, headers
        except json.JSONDecodeError:
            # If not JSON, return the text with proper structure
            # Clean up the response to remove any markdown formatting
            clean_text = response_text.replace("```json", "").replace("```", "").strip()
            
            try:
                # Try one more time with cleaned text
                lesson_plan = json.loads(clean_text)
                return json.dumps(lesson_plan), 200, headers
            except json.JSONDecodeError:
                # If still not JSON, return the text with proper structure
                lesson_plan = {
                    "topic": topic,
                    "gradeLevel": grade_level,
                    "rawResponse": response_text
                }
                return json.dumps(lesson_plan), 200, headers
            
    except ValueError as e:
        # Environment variable errors
        return json.dumps({'error': str(e)}), 500, headers
    except Exception as e:
        # Catch all other exceptions
        import traceback
        return json.dumps({
            'error': 'Internal server error',
            'details': str(e),
            'traceback': traceback.format_exc()
        }), 500, headers
