using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

public class GetMesh : MonoBehaviour
{
    static public Mesh GetHighLodGrass()
    {
        Mesh mesh = new Mesh();
        mesh.vertices = new Vector3[]
        {
            new Vector3(0, 0, 0.3f),
            new Vector3(0, 0, -0.3f),
            new Vector3(0, 1, 0.3f),
            new Vector3(0, 1, -0.3f),
            
        };
        mesh.triangles = new int[] {
            0, 3, 1,
            0, 2, 3
        };

        mesh.colors = new Color[] {
            //Y height , Z offset , 0 , 0
            new Color(0,0,0,0),
            new Color(0,0,0,0),
            new Color(0,0,0,0),
            new Color(0,0,0,0),
        };
        mesh.uv = new Vector2[]
        {
            new Vector2(0, 0),
            new Vector2(0, 0),
            new Vector2(0, 0),
            new Vector2(0, 0),
            
        };

        return mesh;
    }
}
