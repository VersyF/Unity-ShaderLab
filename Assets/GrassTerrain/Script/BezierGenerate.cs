using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class BezierGenerate : MonoBehaviour
{
    public Transform p0;
    public Transform p1;
    public Transform p2;
    public Transform p3;

    public int detail = 20;
    public float gizWeight = 0.1f;
    public Color gizLine = Color.green;
    public Color gizPoint = Color.yellow;
    public float offset = 0.5f;

    public Vector3 GetCubicBezierPoint(Vector3 p0, Vector3 p1, Vector3 p2, Vector3 p3, float t)
    {
        float omt = 1 - t;
        float omt2 = omt * omt;
        float t2 = t * t; 
        return p0 * (omt * omt2)  +
                   p1 * 3 * omt2 * t  +
                   p2 * 3 * omt * t2 +
                   p3 * t2 * t ;
    }

    void OnDrawGizmos()
    {
        Gizmos.color = gizPoint;
        Gizmos.DrawSphere(p0.position, gizWeight);
        Gizmos.DrawSphere(p1.position, gizWeight);
        Gizmos.DrawSphere(p2.position, gizWeight);
        Gizmos.DrawSphere(p3.position, gizWeight);

        Gizmos.color = Color.gray;
        Gizmos.DrawLine(p0.position, p1.position);
        Gizmos.DrawLine(p1.position, p2.position);
        Gizmos.DrawLine (p2.position, p3.position);

        Vector3 p5 = p0.position * offset + p1.position * (1 - offset);
        Vector3 p6 = p1.position * offset + p2.position * (1 - offset);
        Vector3 p7 = p2.position * offset + p3.position * (1 - offset);
        Vector3 p8 = p5 * offset + p6 * (1 - offset);
        Vector3 p9 = p6 * offset + p7 * (1 - offset);
        Gizmos.DrawLine(p5, p6);
        Gizmos.DrawLine(p6, p7);

        Gizmos.color = Color.red;
        Gizmos.DrawLine(p8, p9);

        Gizmos.color = gizLine;

        Vector3 previous = p0.position;
        for(int i = 1; i <= detail; i++)                //为什么这里把'='删了，整个线就不显示了
        {
            float t = (float)i / detail;                        //这里要加float！！
            Vector3 nextpoint = GetCubicBezierPoint(p0.position, p1.position, p2.position, p3.position, t);
            Gizmos.DrawLine(previous, nextpoint);
            previous = nextpoint;
        }

    }
}
