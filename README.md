# GainGrid

A minimalist workout tracking app that helps you maintain consistency in your fitness journey. Inspired by GitHub's activity graph, GainGrid turns your workouts into daily "commits" to help you build and maintain your exercise streak.

%xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<app_description>
    <app_name>GainGrid</app_name>
    <purpose>
        A fitness tracking application that gamifies workout consistency by treating exercise sessions as code commits, visualizing progress through a GitHub-style activity graph.
    </purpose>

    <core_features>
        <feature name="workout_planning">
            <description>Pre-configured 5-day split workout plan with customization options</description>
            <days>
                <day name="Monday">Chest focused exercises</day>
                <day name="Tuesday">Shoulders focused exercises</day>
                <day name="Wednesday">Legs focused exercises</day>
                <day name="Thursday">Back focused exercises</day>
                <day name="Friday">Biceps and Triceps focused exercises</day>
                <day name="Saturday">Optional cardio/rest day</day>
                <day name="Sunday">Rest day</day>
            </days>
        </feature>

        <feature name="exercise_tracking">
            <components>
                <component name="set_logging">
                    <fields>
                        <field>Weight used</field>
                        <field>Repetitions performed</field>
                        <field>Optional notes</field>
                    </fields>
                </component>
                <component name="progress_visualization">
                    <type>GitHub-style activity heat map</type>
                    <metrics>
                        <metric>Workout frequency</metric>
                        <metric>Exercise completion</metric>
                    </metrics>
                </component>
            </components>
        </feature>

        <feature name="workout_history">
            <storage>
                <type>Local JSON storage</type>
                <data_points>
                    <point>Exercise details</point>
                    <point>Weights and reps</point>
                    <point>Date and time</point>
                    <point>Notes</point>
                </data_points>
            </storage>
        </feature>
    </core_features>

    <user_experience>
        <interface>
            <style>Minimalist and clean</style>
            <navigation>Single page with modal detail views</navigation>
            <theme>System-native dark/light mode support</theme>
        </interface>
        
        <workflow>
            <step order="1">View weekly workout plan</step>
            <step order="2">Select day to log exercises</step>
            <step order="3">Track sets and reps</step>
            <step order="4">Complete workout to create activity "commit"</step>
            <step order="5">View progress in activity graph</step>
        </workflow>
    </user_experience>

    <technical_details>
        <platform>iOS</platform>
        <framework>SwiftUI</framework>
        <architecture>MVVM</architecture>
        <data_persistence>Local JSON storage</data_persistence>
        <dependencies>
            <dependency>SwiftUI</dependency>
            <dependency>Foundation</dependency>
        </dependencies>
    </technical_details>

    <accessibility>
        <features>
            <feature>VoiceOver support</feature>
            <feature>Dynamic type scaling</feature>
            <feature>High contrast support</feature>
        </features>
    </accessibility>
</app_description>
``` 
