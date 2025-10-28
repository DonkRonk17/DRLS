#!/usr/bin/env python3
"""
DRGUI AI Designer - Natural Language AI Assistant
Provides intelligent UI design assistance through natural language processing.
"""

import logging
import queue
import threading
import time
from typing import Dict, Any, List, Optional, Callable
import json

# AI and NLP libraries
try:
    import openai
    OPENAI_AVAILABLE = True
except ImportError:
    OPENAI_AVAILABLE = False
    logging.warning("OpenAI library not available. Some AI features will be disabled.")

try:
    from transformers import pipeline, AutoTokenizer, AutoModelForCausalLM
    import torch
    TRANSFORMERS_AVAILABLE = True
except ImportError:
    TRANSFORMERS_AVAILABLE = False
    logging.warning("Transformers library not available. Local AI features will be disabled.")

class AIAssistant:
    """
    AI-powered assistant for WoW UI design
    
    Provides:
    - Natural language UI modification commands
    - Smart layout suggestions
    - Context-aware recommendations
    - Style learning and adaptation
    - Performance optimization suggestions
    """
    
    def __init__(self, settings=None, message_queue=None):
        """Initialize the AI Assistant"""
        self.logger = logging.getLogger(__name__)
        
        # Use provided settings or create default
        if settings is None:
            from config.settings_manager import SettingsManager
            settings = SettingsManager()
        self.settings = settings
        
        # Message queue for communication
        if message_queue is None:
            import queue
            message_queue = queue.Queue()
        self.message_queue = message_queue
        
        # AI model state
        self.openai_client = None
        self.local_model = None
        self.local_tokenizer = None
        
        # Processing state
        self.is_processing = False
        self.current_context = {}
        self.conversation_history = []
        self.user_preferences = {}
        
        # UI state tracking
        self.current_layout = {}
        self.layout_history = []
        self.style_patterns = {}
        
        # Initialize AI models
        self._initialize_ai_models()
        
        # Load user learning data
        self._load_learning_data()
        
    def _initialize_ai_models(self):
        """Initialize available AI models"""
        try:
            # Initialize OpenAI if available and configured
            if OPENAI_AVAILABLE:
                api_key = self.settings.get("ai.openai.api_key")
                if api_key:
                    openai.api_key = api_key
                    self.openai_client = openai
                    self.logger.info("OpenAI client initialized")
                else:
                    self.logger.info("OpenAI API key not configured")
            
            # Initialize local AI model if available
            if TRANSFORMERS_AVAILABLE and self.settings.get("ai.local_ai.enabled"):
                self._initialize_local_model()
                
        except Exception as e:
            self.logger.error(f"Error initializing AI models: {e}")
    
    def _initialize_local_model(self):
        """Initialize local AI model for offline operation"""
        try:
            model_name = "microsoft/DialoGPT-medium"  # Conversational AI model
            
            self.logger.info("Loading local AI model...")
            self.local_tokenizer = AutoTokenizer.from_pretrained(model_name)
            self.local_model = AutoModelForCausalLM.from_pretrained(model_name)
            
            # Add padding token if missing
            if self.local_tokenizer.pad_token is None:
                self.local_tokenizer.pad_token = self.local_tokenizer.eos_token
            
            self.logger.info("Local AI model loaded successfully")
            
        except Exception as e:
            self.logger.error(f"Error loading local AI model: {e}")
            self.local_model = None
            self.local_tokenizer = None
    
    def _load_learning_data(self):
        """Load user preference learning data"""
        try:
            # Load from settings
            self.user_preferences = self.settings.get("user", {})
            self.style_patterns = {}
            
            self.logger.info("Learning data loaded")
            
        except Exception as e:
            self.logger.error(f"Error loading learning data: {e}")
    
    def start_processing(self, shutdown_event: threading.Event):
        """Start AI processing loop"""
        self.logger.info("AI Assistant processing started")
        self.is_processing = True
        
        while not shutdown_event.is_set() and self.is_processing:
            try:
                # Process any pending AI requests
                self._process_pending_requests()
                
                # Periodic analysis and suggestions
                self._periodic_analysis()
                
                # Small delay to prevent excessive CPU usage
                time.sleep(0.1)
                
            except Exception as e:
                self.logger.error(f"Error in AI processing loop: {e}")
        
        self.logger.info("AI Assistant processing stopped")
    
    def _process_pending_requests(self):
        """Process any pending AI requests from the queue"""
        # This would be implemented to handle requests from the UI
        pass
    
    def _periodic_analysis(self):
        """Perform periodic analysis and generate suggestions"""
        # This would analyze the current UI state and generate suggestions
        pass
    
    async def process_natural_language_command(self, command: str, context: Dict[str, Any] = None) -> Dict[str, Any]:
        """
        Process a natural language UI design command
        
        Args:
            command: User's natural language command
            context: Current UI context information
            
        Returns:
            Dict containing response and action data
        """
        try:
            self.logger.info(f"Processing command: {command}")
            
            # Update context
            if context:
                self.current_context.update(context)
            
            # Add to conversation history
            self.conversation_history.append({
                "role": "user",
                "content": command,
                "timestamp": time.time(),
                "context": context or {}
            })
            
            # Generate response using available AI model
            if self.openai_client and self.settings.get("ai.openai.api_key"):
                response = await self._process_with_openai(command)
            elif self.local_model:
                response = self._process_with_local_model(command)
            else:
                response = self._process_with_fallback(command)
            
            # Add response to history
            self.conversation_history.append({
                "role": "assistant",
                "content": response["message"],
                "timestamp": time.time(),
                "actions": response.get("actions", [])
            })
            
            # Learn from interaction
            self._learn_from_interaction(command, response)
            
            return response
            
        except Exception as e:
            self.logger.error(f"Error processing command: {e}")
            return {
                "message": "I apologize, but I encountered an error processing your request. Please try again.",
                "error": str(e),
                "actions": []
            }
    
    async def _process_with_openai(self, command: str) -> Dict[str, Any]:
        """Process command using OpenAI GPT"""
        try:
            # Build context-aware prompt
            prompt = self._build_wow_ui_prompt(command)
            
            response = await openai.ChatCompletion.acreate(
                model=self.settings.get("ai.openai.model", "gpt-4"),
                messages=prompt,
                max_tokens=self.settings.get("ai.openai.max_tokens", 2000),
                temperature=self.settings.get("ai.openai.temperature", 0.7)
            )
            
            # Parse response
            ai_response = response.choices[0].message.content
            return self._parse_ai_response(ai_response)
            
        except Exception as e:
            self.logger.error(f"OpenAI processing error: {e}")
            return self._process_with_fallback(command)
    
    def _process_with_local_model(self, command: str) -> Dict[str, Any]:
        """Process command using local AI model"""
        try:
            # Build context for local model
            context_prompt = self._build_local_prompt(command)
            
            # Tokenize input
            inputs = self.local_tokenizer.encode(
                context_prompt, 
                return_tensors="pt",
                max_length=512,
                truncation=True
            )
            
            # Generate response
            with torch.no_grad():
                outputs = self.local_model.generate(
                    inputs,
                    max_length=inputs.shape[1] + 100,
                    num_return_sequences=1,
                    temperature=0.7,
                    do_sample=True,
                    pad_token_id=self.local_tokenizer.pad_token_id
                )
            
            # Decode response
            response = self.local_tokenizer.decode(
                outputs[0][inputs.shape[1]:], 
                skip_special_tokens=True
            )
            
            return self._parse_local_response(response, command)
            
        except Exception as e:
            self.logger.error(f"Local AI processing error: {e}")
            return self._process_with_fallback(command)
    
    def _process_with_fallback(self, command: str) -> Dict[str, Any]:
        """Process command using rule-based fallback system"""
        self.logger.info("Using fallback AI processing")
        
        # Simple keyword-based processing
        command_lower = command.lower()
        
        # Health bar related commands
        if any(word in command_lower for word in ["health", "hp", "life"]):
            if "bigger" in command_lower or "larger" in command_lower:
                return {
                    "message": "I'll make your health bar larger. Increasing size by 25% and enhancing visibility.",
                    "actions": [
                        {"type": "resize_element", "element": "player_frame", "scale": 1.25},
                        {"type": "highlight_element", "element": "player_frame"}
                    ]
                }
            elif "move" in command_lower:
                return {
                    "message": "I'll help you reposition your health bar. Where would you like it moved?",
                    "actions": [
                        {"type": "enable_drag_mode", "element": "player_frame"}
                    ]
                }
        
        # Action bar related commands
        elif any(word in command_lower for word in ["action", "spell", "ability", "button"]):
            if "center" in command_lower:
                return {
                    "message": "Centering your action bars for optimal accessibility. This layout works well for most classes.",
                    "actions": [
                        {"type": "move_element", "element": "action_bars", "position": "bottom_center"},
                        {"type": "apply_template", "template": "centered_bars"}
                    ]
                }
        
        # Layout related commands
        elif any(word in command_lower for word in ["layout", "ui", "interface"]):
            if "minimalist" in command_lower or "clean" in command_lower:
                return {
                    "message": "Creating a clean, minimalist layout. Hiding non-essential elements and organizing key frames.",
                    "actions": [
                        {"type": "apply_template", "template": "minimalist"},
                        {"type": "optimize_layout", "style": "minimal"}
                    ]
                }
            elif "raid" in command_lower:
                return {
                    "message": "Optimizing for raid content. Emphasizing raid frames and important cooldown tracking.",
                    "actions": [
                        {"type": "apply_template", "template": "raid_healing"},
                        {"type": "show_raid_frames", "size": "large"}
                    ]
                }
        
        # Default helpful response
        return {
            "message": f"I understand you want to modify your UI. While I'm processing your request for '{command}', you can also drag and drop elements directly or use the properties panel for precise adjustments.",
            "actions": [
                {"type": "highlight_tools", "tools": ["drag_drop", "properties_panel"]}
            ]
        }
    
    def _build_wow_ui_prompt(self, command: str) -> List[Dict[str, str]]:
        """Build context-aware prompt for OpenAI"""
        
        # System prompt with WoW UI expertise
        system_prompt = """
        You are an expert World of Warcraft UI designer with deep knowledge of:
        - WoW interface elements and their optimal positioning
        - Class-specific UI needs and role requirements
        - Combat mechanics and UI performance impact
        - Accessibility and usability principles
        - Current TWW expansion features and changes

        You help users design optimal UI layouts through natural language commands.
        Always provide specific, actionable responses with clear reasoning.
        
        Current user context:
        - Class: {class_name}
        - Role: {role}
        - Content focus: {content_type}
        - Current layout elements: {elements}
        
        Respond with helpful advice and specific UI modification suggestions.
        Format your response as JSON with 'message' and 'actions' fields.
        """.format(
            class_name=self.user_preferences.get("character", {}).get("class", "unknown"),
            role=self.user_preferences.get("character", {}).get("role", "dps"),
            content_type=self.user_preferences.get("content_preferences", {}).get("primary_content", "mixed"),
            elements=list(self.current_layout.keys()) if self.current_layout else []
        )
        
        # Build conversation history
        messages = [{"role": "system", "content": system_prompt}]
        
        # Add recent conversation history
        for msg in self.conversation_history[-10:]:  # Last 10 messages
            messages.append({
                "role": msg["role"],
                "content": msg["content"]
            })
        
        # Add current command
        messages.append({"role": "user", "content": command})
        
        return messages
    
    def _build_local_prompt(self, command: str) -> str:
        """Build prompt for local AI model"""
        context = f"""
        WoW UI Designer Assistant
        User playing: {self.user_preferences.get('character', {}).get('class', 'Warrior')}
        Role: {self.user_preferences.get('character', {}).get('role', 'DPS')}
        
        User request: {command}
        
        Assistant response:"""
        
        return context
    
    def _parse_ai_response(self, response: str) -> Dict[str, Any]:
        """Parse AI response and extract actions"""
        try:
            # Try to parse as JSON first
            if response.strip().startswith('{'):
                return json.loads(response)
            
            # Fallback to text response
            return {
                "message": response,
                "actions": self._extract_actions_from_text(response)
            }
            
        except json.JSONDecodeError:
            return {
                "message": response,
                "actions": self._extract_actions_from_text(response)
            }
    
    def _parse_local_response(self, response: str, original_command: str) -> Dict[str, Any]:
        """Parse local AI model response"""
        return {
            "message": response.strip() if response.strip() else "I can help you with that UI modification.",
            "actions": self._infer_actions_from_command(original_command)
        }
    
    def _extract_actions_from_text(self, text: str) -> List[Dict[str, Any]]:
        """Extract actionable commands from AI response text"""
        actions = []
        text_lower = text.lower()
        
        # Look for common action patterns
        if "resize" in text_lower or "bigger" in text_lower or "larger" in text_lower:
            actions.append({"type": "suggest_resize", "direction": "increase"})
        
        if "move" in text_lower or "position" in text_lower:
            actions.append({"type": "suggest_move", "interactive": True})
        
        if "template" in text_lower or "layout" in text_lower:
            actions.append({"type": "suggest_template", "category": "general"})
        
        return actions
    
    def _infer_actions_from_command(self, command: str) -> List[Dict[str, Any]]:
        """Infer actions from the original user command"""
        actions = []
        command_lower = command.lower()
        
        # Simple action inference
        if any(word in command_lower for word in ["move", "position"]):
            actions.append({"type": "enable_drag_mode"})
        
        if any(word in command_lower for word in ["bigger", "larger", "resize"]):
            actions.append({"type": "show_resize_handles"})
        
        if any(word in command_lower for word in ["template", "layout", "style"]):
            actions.append({"type": "show_template_suggestions"})
        
        return actions
    
    def _learn_from_interaction(self, command: str, response: Dict[str, Any]):
        """Learn from user interactions to improve future suggestions"""
        try:
            # Track command patterns
            command_type = self._classify_command(command)
            
            # Update style patterns
            if command_type not in self.style_patterns:
                self.style_patterns[command_type] = []
            
            self.style_patterns[command_type].append({
                "command": command,
                "response": response,
                "timestamp": time.time(),
                "context": self.current_context.copy()
            })
            
            # Keep only recent patterns (last 100 per type)
            if len(self.style_patterns[command_type]) > 100:
                self.style_patterns[command_type] = self.style_patterns[command_type][-100:]
            
            self.logger.debug(f"Learned from command type: {command_type}")
            
        except Exception as e:
            self.logger.error(f"Error in learning from interaction: {e}")
    
    def _classify_command(self, command: str) -> str:
        """Classify command type for learning purposes"""
        command_lower = command.lower()
        
        if any(word in command_lower for word in ["move", "position", "place"]):
            return "positioning"
        elif any(word in command_lower for word in ["resize", "bigger", "smaller", "size"]):
            return "sizing"
        elif any(word in command_lower for word in ["color", "theme", "style", "appearance"]):
            return "styling"
        elif any(word in command_lower for word in ["template", "layout", "preset"]):
            return "templates"
        elif any(word in command_lower for word in ["hide", "show", "visible", "invisible"]):
            return "visibility"
        else:
            return "general"
    
    def get_smart_suggestions(self, context: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Generate smart suggestions based on current context"""
        suggestions = []
        
        try:
            # Analyze current context
            user_class = context.get("character", {}).get("class", "")
            user_role = context.get("character", {}).get("role", "")
            content_type = context.get("scenario", "general")
            
            # Generate role-specific suggestions
            if user_role == "healer":
                suggestions.extend([
                    {
                        "title": "Optimize Raid Frames",
                        "description": "Enhance raid frame visibility and positioning for efficient healing",
                        "action": {"type": "apply_template", "template": "healer_raid_frames"}
                    },
                    {
                        "title": "Cleanse Indicator Setup",
                        "description": "Add dispellable debuff highlighting to raid frames",
                        "action": {"type": "enable_feature", "feature": "dispel_highlighting"}
                    }
                ])
            
            elif user_role == "tank":
                suggestions.extend([
                    {
                        "title": "Threat Monitoring",
                        "description": "Optimize threat display and enemy positioning",
                        "action": {"type": "apply_template", "template": "tank_threat_monitor"}
                    },
                    {
                        "title": "Cooldown Tracking", 
                        "description": "Enhance defensive cooldown visibility",
                        "action": {"type": "enable_feature", "feature": "defensive_cd_tracker"}
                    }
                ])
            
            # Content-specific suggestions
            if content_type == "raid":
                suggestions.append({
                    "title": "Raid Environment Setup",
                    "description": "Optimize UI for 20-person raid encounters",
                    "action": {"type": "apply_template", "template": "raid_optimized"}
                })
            
            elif content_type == "pvp":
                suggestions.append({
                    "title": "PvP Combat Setup",
                    "description": "Focus on enemy tracking and burst indicators",
                    "action": {"type": "apply_template", "template": "pvp_focused"}
                })
            
        except Exception as e:
            self.logger.error(f"Error generating suggestions: {e}")
        
        return suggestions
    
    def analyze_layout_performance(self, layout_data: Dict[str, Any]) -> Dict[str, Any]:
        """Analyze layout for performance and usability issues"""
        analysis = {
            "issues": [],
            "suggestions": [],
            "performance_score": 100,
            "usability_score": 100
        }
        
        try:
            # Check for common issues
            if layout_data.get("overlapping_elements"):
                analysis["issues"].append({
                    "type": "overlap",
                    "severity": "medium",
                    "description": "Some UI elements are overlapping",
                    "fix": "Adjust positioning to prevent element overlap"
                })
                analysis["usability_score"] -= 15
            
            if layout_data.get("too_many_visible_elements", 0) > 20:
                analysis["issues"].append({
                    "type": "clutter",
                    "severity": "low", 
                    "description": "UI may be cluttered with too many visible elements",
                    "fix": "Consider hiding non-essential elements"
                })
                analysis["usability_score"] -= 10
            
            # Generate improvement suggestions
            analysis["suggestions"] = [
                "Consider using consistent scaling across similar elements",
                "Group related UI elements together for better organization",
                "Leave some empty space for better visual clarity"
            ]
            
        except Exception as e:
            self.logger.error(f"Error analyzing layout: {e}")
        
        return analysis
    
    def cleanup(self):
        """Clean up AI resources"""
        self.is_processing = False
        
        # Clean up any loaded models
        if hasattr(self, 'local_model') and self.local_model:
            del self.local_model
        
        if hasattr(self, 'local_tokenizer') and self.local_tokenizer:
            del self.local_tokenizer
        
        self.logger.info("AI Assistant cleanup completed")