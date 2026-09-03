using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SENearParticle : MonoBehaviour
{
    public Camera cam;
    public float positionOffX = 0;
    public float positionOffY = 0;
    public float positionOffZ = 0;

    private Vector3 camPos;
    // Start is called before the first frame update
    void Start()
    {
        camPos = cam.transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        camPos = cam.transform.position;
        Vector3 targetPos = new Vector3(camPos.x + positionOffX, camPos.y + positionOffY, camPos.z + positionOffZ);
        this.transform.position = targetPos;
    }
}
