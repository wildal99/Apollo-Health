cl import from react { useState } 
cl import from jac:client_runtime { jacIsLoggedIn }

cl {
    def:pub OnboardingScreen() -> any {
        [name, setName] = useState("");
        [language, setLanguage] = useState("English");
        [background, setBackground] = useState("");
        [provider, setProvider] = useState("");
        [submitted, setSubmitted] = useState(False);
        [welcomeMsg, setWelcomeMsg] = useState("");
        [loading, setLoading] = useState(False);

        async def handleSubmit() -> None {
            if not name or not provider {
                return;
            }
            setLoading(True);
            response = await root spawn onboard_patient(
                name=name,
                language=language,
                cultural_background=background,
                provider_id=provider
            );
            setWelcomeMsg(response.reports[0]);
            setSubmitted(True);
            setLoading(False);
        }

        if submitted {
            return <div style={{
                "minHeight": "100vh",
                "background": "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
                "display": "flex",
                "alignItems": "center",
                "justifyContent": "center",
                "fontFamily": "system-ui, sans-serif"
            }}>
                <div style={{
                    "background": "white",
                    "borderRadius": "24px",
                    "padding": "48px",
                    "maxWidth": "480px",
                    "width": "90%",
                    "textAlign": "center",
                    "boxShadow": "0 20px 60px rgba(0,0,0,0.15)"
                }}>
                    <div style={{"fontSize": "64px", "marginBottom": "16px"}}>✅</div>
                    <h2 style={{
                        "color": "#1a1a2e",
                        "fontSize": "24px",
                        "marginBottom": "16px"
                    }}>Welcome to HealthBridge!</h2>
                    <p style={{
                        "color": "#555",
                        "fontSize": "16px",
                        "lineHeight": "1.6",
                        "marginBottom": "32px"
                    }}>{welcomeMsg}</p>
                    <div style={{
                        "background": "#f0f4ff",
                        "borderRadius": "12px",
                        "padding": "16px",
                        "color": "#667eea",
                        "fontSize": "14px"
                    }}>
                        Linked to provider: <strong>{provider}</strong>
                    </div>
                </div>
            </div>;
        }

        return <div style={{
            "minHeight": "100vh",
            "background": "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
            "display": "flex",
            "alignItems": "center",
            "justifyContent": "center",
            "fontFamily": "system-ui, sans-serif",
            "padding": "20px"
        }}>
            <div style={{
                "background": "white",
                "borderRadius": "24px",
                "padding": "48px",
                "maxWidth": "480px",
                "width": "100%",
                "boxShadow": "0 20px 60px rgba(0,0,0,0.15)"
            }}>
                <div style={{"textAlign": "center", "marginBottom": "32px"}}>
                    <div style={{"fontSize": "48px", "marginBottom": "8px"}}>🏥</div>
                    <h1 style={{
                        "color": "#1a1a2e",
                        "fontSize": "28px",
                        "fontWeight": "700",
                        "margin": "0 0 8px 0"
                    }}>HealthBridge</h1>
                    <p style={{"color": "#888", "fontSize": "15px", "margin": "0"}}>
                        Your personal health navigator
                    </p>
                </div>

                <div style={{"marginBottom": "20px"}}>
                    <label style={{
                        "display": "block",
                        "color": "#333",
                        "fontSize": "14px",
                        "fontWeight": "600",
                        "marginBottom": "8px"
                    }}>Full Name *</label>
                    <input
                        type="text"
                        placeholder="e.g. Maria Santos"
                        value={name}
                        onChange={lambda e: any -> None { setName(e.target.value); }}
                        style={{
                            "width": "100%",
                            "padding": "12px 16px",
                            "borderRadius": "10px",
                            "border": "2px solid #e8e8e8",
                            "fontSize": "15px",
                            "outline": "none",
                            "boxSizing": "border-box",
                            "transition": "border-color 0.2s"
                        }}
                    />
                </div>

                <div style={{"marginBottom": "20px"}}>
                    <label style={{
                        "display": "block",
                        "color": "#333",
                        "fontSize": "14px",
                        "fontWeight": "600",
                        "marginBottom": "8px"
                    }}>Preferred Language</label>
                    <select
                        value={language}
                        onChange={lambda e: any -> None { setLanguage(e.target.value); }}
                        style={{
                            "width": "100%",
                            "padding": "12px 16px",
                            "borderRadius": "10px",
                            "border": "2px solid #e8e8e8",
                            "fontSize": "15px",
                            "outline": "none",
                            "boxSizing": "border-box",
                            "background": "white"
                        }}
                    >
                        <option value="English">English</option>
                        <option value="Spanish">Español</option>
                        <option value="Portuguese">Português</option>
                        <option value="Mandarin">中文</option>
                        <option value="Hindi">हिन्दी</option>
                        <option value="Arabic">العربية</option>
                        <option value="French">Français</option>
                        <option value="Korean">한국어</option>
                        <option va