<%@ Page Title="Home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="Zero_to_AI.Home" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    </asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="hero-section">
        <h1 class="hero-title">Master AI from Scratch</h1>
        <p class="hero-subtitle">
            Zero to AI is the ultimate interactive platform for computer science students. 
            Simulate neural networks, visualize data, and track your learning journey—all in one place.
        </p>
        
        <a href="Dashboard.aspx" class="cta-button">
            <i class="fas fa-rocket"></i> Get Started Now
        </a>
    </div>


    <div class="features-grid">
        
        <div class="feature-card">
            <i class="fas fa-brain feature-icon"></i>
            <div class="feature-title">Interactive Simulations</div>
            <div class="feature-desc">
                Don't just read about AI. Build and train models directly in your browser with our visual tools.
            </div>
        </div>

        <div class="feature-card">
            <i class="fas fa-chart-pie feature-icon"></i>
            <div class="feature-title">Real-time Analytics</div>
            <div class="feature-desc">
                Track your progress with dynamic charts. See your strengths and areas for improvement instantly.
            </div>
        </div>

        <div class="feature-card">
            <i class="fas fa-laptop-code feature-icon"></i>
            <div class="feature-title">Student Dashboard</div>
            <div class="feature-desc">
                A personalized space to manage your courses, assignments, and upcoming deadlines efficiently.
            </div>
        </div>

    </div>

    <div class="stats-row">
        <div class="stat-item">
            <h2>100+</h2>
            <span>Modules</span>
        </div>
        <div class="stat-item">
            <h2>500+</h2>
            <span>Active Students</span>
        </div>
        <div class="stat-item">
            <h2>24/7</h2>
            <span>AI Support</span>
        </div>
    </div>

</asp:Content>