using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CreateGrass : MonoBehaviour
{
    public Material mat;
    // Start is called before the first frame update
    void Start()
    {
        Mesh mesh = GrassMesh.CreateHighLodGrass();
        MeshFilter filter = gameObject.AddComponent<MeshFilter>();
        MeshRenderer renderer = gameObject.AddComponent<MeshRenderer>();
        filter.sharedMesh = mesh;
        renderer.sharedMaterial = mat;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
