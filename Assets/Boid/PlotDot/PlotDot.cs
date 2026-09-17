using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class PlotDot : MonoBehaviour
{
    public bool VIEW_3D = false;
    public int dotNum = 10;
    [Range(0f, 1f)]
    public float angleOff = 0;
    public float radius = 0.01f;
    [Range (-1f, 1f)]
    public float pow = 1f;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        

    }

    private void OnDrawGizmos()
    {
        if (VIEW_3D)
        {
            DrawGraph3D();
        }
        else
        {
            DrawGraph2D();
        }
            
    }

    void DrawGraph2D()
    {
        for (int i = 0; i < dotNum; i++)
        {
            float dst = Mathf.Pow(i / (dotNum - 1f), pow);
            float angle = angleOff * i * 2 * Mathf.PI;
            float x = Mathf.Cos(angle) * dst;
            float y = Mathf.Sin(angle) * dst;
            AddDot(new Vector2(x, y));
        }
    }

    void DrawGraph3D()
    {
        for (int i = 0; i < dotNum; i++)
        {
            float dst = Mathf.Pow(i / (dotNum - 1f), pow);
            float angle = angleOff * i * 2 * Mathf.PI;

            float alpha = dst * Mathf.PI;
            float beta = angle;

            float x3d = Mathf.Sin(alpha) * Mathf.Cos(beta);
            float y3d = Mathf.Sin(alpha) * Mathf.Sin(beta);
            float z3d = Mathf.Cos(alpha);

            AddDot(new Vector3(x3d, y3d, z3d));
        }
    }

    void DrawGraph3D2()
    {
        for (int i = 0; i < dotNum; i++)
        {
            float dst = Mathf.Pow(i / (dotNum - 1f), pow);
            float angle = angleOff * i * 2 * Mathf.PI;
            float xAngle = Mathf.Cos(angle) * dst;
            float yAngle = Mathf.Sin(angle) * dst;

            float x = Mathf.Sin(xAngle * Mathf.PI) * (1f - Mathf.Abs(2f * dst - 1f));
            float y = Mathf.Sin(yAngle * Mathf.PI) * (1f - Mathf.Abs(2f * dst - 1f));
            float z = Mathf.Cos(dst * Mathf.PI) * -1;

            AddDot(new Vector3(x, y, z));
        }
    }

    void AddDot(Vector3 axis)
    {
        Gizmos.color = Color.red;
        Gizmos.DrawSphere(axis + this.transform.position, radius);
    }

}

