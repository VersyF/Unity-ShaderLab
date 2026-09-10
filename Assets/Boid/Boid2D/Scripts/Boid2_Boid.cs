using System.Collections;
using System.Linq;
using System.Collections.Generic;
using UnityEngine;

public class Boid : MonoBehaviour
{
    public float speed = 2;
    public float turnSpeedMax = 100f;
    public float viewDistance = 2;

    Rigidbody2D rb;
    Transform transform;

    private List<GameObject> boidsInView = new List<GameObject>();
    private Vector2 topLeft;
    private Vector2 bottomRight;
    private float turnSpeed = 0;

    void Start()
    {
        //赋予初始速度
        rb = GetComponent<Rigidbody2D>();
        transform = GetComponent<Transform>();


        //数量少，获取全部Boids
        //boidsInView = Boid2_CreateBoids.instance.boidsList.ToList();

        //
        topLeft = Boid2_CreateBoids.instance.topLeft;
        bottomRight = Boid2_CreateBoids.instance.bottomRight;

    }
    
    void Update()
    {
        Separate();
    }

    private void FixedUpdate()
    {
        rb.velocity = transform.up * speed;
        CheckEdge();
    }

    //分离
    void Separate()
    {
        Vector2 forwardVector = this.transform.up;
        Vector2 fixedVector = forwardVector;

        float currentNearestDis = viewDistance;                   //记录最近距离
        foreach (GameObject go in Boid2_CreateBoids.instance.boidsList)
        {
            if (go == this.gameObject) continue;

            Vector3 distancePos = (this.transform.position - go.transform.position);
            Vector2 distanceVec = new Vector2(distancePos.x, distancePos.y);
            float distance = distanceVec.magnitude;
            currentNearestDis = Mathf.Min(distance, currentNearestDis);                     //记录这次最近距离
            float distanceTense = Mathf.Clamp01((viewDistance - distance) / viewDistance);                  //确定最大影响范围
            float pushScale = Mathf.Lerp(0, 3, distanceTense);                  //根据距离确定影响forward改变的程度

            turnSpeed = Mathf.Lerp(0, turnSpeedMax, Mathf.Clamp01( (viewDistance - currentNearestDis) / viewDistance));

            fixedVector += pushScale * distanceVec.normalized;
        }

        Vector2 worldUp = new Vector2(0, 1);
        float angle = Vector2.Angle(fixedVector, worldUp);
        angle *= Mathf.Sign(worldUp.x * fixedVector.y - worldUp.y * fixedVector.x);
        TurnTo(angle);
    }

    public void TurnTo(float targetAngleDegrees)
    {
        float currentAngle = rb.rotation; // Rigidbody2D的rotation是Z轴角度
        float newAngle = Mathf.MoveTowardsAngle(
            currentAngle,
            targetAngleDegrees,
            turnSpeed * Time.fixedDeltaTime
        );
        rb.MoveRotation(newAngle);
    }

    void CheckEdge()
    {
        Vector2 position = transform.position;
        if (position.x < topLeft.x)
        {
            position.x = bottomRight.x;
        }
        else if(position.x > bottomRight.x)
        {
            position.x = topLeft.x;
        }

        if (position.y < bottomRight.y)
        {
            position.y = topLeft.y;
        }
        else if (position.y > topLeft.y)
        {
            position.y = bottomRight.y;
        }

        this.transform.position = position;
    }
}
