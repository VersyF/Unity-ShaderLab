using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[InitializeOnLoad]
public class SceneCornerDisplay : MonoBehaviour
{
    public PlotDot script = null;

    SceneCornerDisplay()
    {
        SceneView.duringSceneGui += OnSceneGUI;
    }

    private void OnSceneGUI(SceneView sceneView)
    {
        if (script == null)
        {
            return;
        }

        Handles.BeginGUI();
        GUILayout.BeginArea(new Rect(10, sceneView.position.height - 80, 300, 70));
        GUILayout.Label($"变量值: {script.dotNum:F2}");
        GUILayout.Label("其他信息...");
        GUILayout.EndArea();
        Handles.EndGUI();
    }
}
