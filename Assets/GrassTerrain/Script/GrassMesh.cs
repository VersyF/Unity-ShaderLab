using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrassMesh
{
    static public Mesh CreateHighLodGrass()
    {
        Mesh mesh = new Mesh();
        mesh.vertices = new Vector3[]
        {
            new Vector3(0, 0, 0.3f),
            new Vector3(0, 0, -0.3f),
            new Vector3(0, 1, 0.3f),
            new Vector3(0, 1, -0.3f),
            new Vector3(0, 2, 0.3f),
            new Vector3(0, 2, -0.3f),
            new Vector3(0, 3, 0.3f),
            new Vector3(0, 3, -0.3f),
            new Vector3(0, 4, 0),
        };
        mesh.triangles = new int[]
        {
            0, 2, 1,
            1, 2, 3,
            2, 4, 3,
            3, 4, 5,
            4, 6, 5,
            5, 6, 7,
            6, 8, 7
        };
        mesh.colors = new Color[] {
            new Color(0, 1, 0, 0),
            new Color(0, -1, 0, 0),
            new Color(0.25f, 1, 0, 0),
            new Color(0.25f, -1, 0, 0),
            new Color(0.5f, 1, 0, 0),
            new Color(0.5f, -1, 0, 0),
            new Color(0.75f, 1, 0, 0),
            new Color(0.75f, -1, 0, 0),
            new Color(1, 0, 0, 0),
        };
        mesh.uv = new Vector2[]
        {
            new Vector2(0, 0),
            new Vector2(0, 0),
            new Vector2(0, 0),
            new Vector2(0, 0),
            new Vector2(0, 0),
            new Vector2(0, 0),
            new Vector2(0, 0),
            new Vector2(0, 0),
            new Vector2(0, 0),
        };
        return mesh;
    }
}
