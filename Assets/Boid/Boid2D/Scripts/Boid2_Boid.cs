using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.VisualScripting.Antlr3.Runtime;
using UnityEngine;

public class Boid : MonoBehaviour
{
    public float speed = 2;
    public float turnSpeedMax = 100f;
    public float viewDistance = 2;

    Rigidbody2D rb;
    Transform transform;

    private List<GameObject> boidsInView;
    private Vector2 topLeft;
    private Vector2 bottomRight;
    private float turnSpeed = 0;

    float currentNearestDis;
    void Start()
    {
        //赋予初始速度
        rb = GetComponent<Rigidbody2D>();
        transform = GetComponent<Transform>();


        //数量少，获取全部Boids
        boidsInView = Boid2_CreateBoids.instance.boidsList;

        //
        topLeft = Boid2_CreateBoids.instance.topLeft;
        bottomRight = Boid2_CreateBoids.instance.bottomRight;

    }
    
    void Update()
    {
        Observe();
    }

    private void FixedUpdate()
    {
        rb.velocity = transform.up * speed;
        CheckEdge();
    }

    //观察
    void Observe()
    {
        Vector2 forwardVector = this.transform.up;
        Vector2 separateVec = forwardVector;
        Vector2 alignVec = new Vector2(0, 0);

        Vector2 targetVec = new Vector2(0, 0);

        currentNearestDis = viewDistance;           //记录最近距离

        foreach (GameObject go in boidsInView)
        {
            if (go == this.gameObject) continue;

            separateVec += Separate(go);
            alignVec += Align(go);
        }

        separateVec = separateVec.normalized;
        alignVec = alignVec.normalized;

        //综合分离与对齐
        targetVec = Vector2.Lerp(separateVec, alignVec, currentNearestDis);

        //加入聚合
        targetVec = Vector2.Lerp(targetVec, Cohension(boidsInView), currentNearestDis);

        //根据向量旋转
        Vector2 worldUp = new Vector2(0, 1);
        float angle = Vector2.Angle(targetVec, worldUp);
        angle *= Mathf.Sign(worldUp.x * targetVec.y - worldUp.y * targetVec.x);
        TurnTo(angle);
    }

    //分离
    Vector2 Separate(GameObject partner)
    {
        Vector3 distancePos = (this.transform.position - partner.transform.position);
        Vector2 distanceVec = new Vector2(distancePos.x, distancePos.y);
        float distance = distanceVec.magnitude;
        currentNearestDis = Mathf.Min(distance, currentNearestDis);                     //记录这次最近距离
        float distanceTense = Mathf.Clamp01( Mathf.Exp(-distance));                  //确定最大影响范围
        float pushScale = Mathf.Lerp(0, 3, distanceTense);                  //根据距离确定影响forward改变的程度

        turnSpeed = Mathf.Lerp(0, turnSpeedMax, Mathf.Clamp01((viewDistance - currentNearestDis) / viewDistance));

        return pushScale * distanceVec.normalized;
    }

    //对齐
    Vector2 Align(GameObject partner)
    {

        return partner.transform.up;
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

    //聚合
    Vector2 Cohension(List<GameObject> partners)
    {
        Vector2 averagePos = Vector2.zero;
        foreach (GameObject partner in partners)
        {
            averagePos += new Vector2(partner.transform.position.x, partner.transform.position.y);
        }
        averagePos /= partners.Count;
        Vector2 targetVec = averagePos - new Vector2(this.transform.position.x, this.transform.position.y);
        return targetVec.normalized;
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
