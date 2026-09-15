using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;

public class Boid3D : MonoBehaviour
{
    //Gizmos toggle
    public bool DRAW_GIZMOS = false;

    private BoidsManager3D manager;
    private Rigidbody rb;

    //Infomation
    private Vector3 currentTarget;
    private List<GameObject> boidsInView;

    // Start is called before the first frame update
    void Start()
    {
        manager = BoidsManager3D.instance;
        rb = GetComponent<Rigidbody>();
        boidsInView = manager.boidsList;
    }

    // Update is called once per frame
    void Update()
    {
        Observe();
    }

    private void FixedUpdate()
    {
        rb.velocity = transform.forward * manager.boidSpeed;
        CheckEdge();
    }

    void CheckEdge()
    {
        Vector3 position = transform.position;

        // X 方向环绕
        if (position.x < manager.minX)
        {
            position.x = manager.maxX;
        }
        else if (position.x > manager.maxX)
        {
            position.x = manager.minX;
        }

        // Y 方向环绕
        if (position.y < manager.minY)
        {
            position.y = manager.maxY;
        }
        else if (position.y > manager.maxY)
        {
            position.y = manager.minY;
        }

        // Z 方向环绕
        if (position.z < manager.minZ)
        {
            position.z = manager.maxZ;
        }
        else if (position.z > manager.maxZ)
        {
            position.z = manager.minZ;
        }

        transform.position = position;
    }

    //
    void Observe()
    {
        Vector3 forwardVector = this.transform.forward;
        Vector3 separateVec = forwardVector;
        Vector3 alignVec = forwardVector;
        Vector3 cohensionVec = forwardVector;

        Vector3 targetVec = new Vector3(0, 0, 0);
        

        float currentNearestDis = manager.boidViewDst;           //记录最近距离

        foreach (GameObject go in boidsInView)
        {
            if (go == this.gameObject) continue;
            if (IsOutOfView(go, manager.boidViewDst)) continue;

            //Separation
            Vector4 seperateResult = Separate(go);
            separateVec += new Vector3(seperateResult.x, seperateResult.y, seperateResult.z);
            currentNearestDis = Mathf.Min(seperateResult.w, currentNearestDis);

            //Alignment
            alignVec += Align(go);
        }

        //转向速度受距离影响
        float turnSpeed = Mathf.Lerp(0, manager.boidTurnSpeedMax, Mathf.Clamp01((manager.boidViewDst - currentNearestDis) / manager.boidViewDst));

        //取模
        separateVec = separateVec.normalized;
        alignVec = alignVec.normalized;

        //综合分离与对齐
        //targetVec = Vector2.Lerp(separateVec, alignVec, currentNearestDis / viewDistance);

        //加入聚合
        cohensionVec = Cohension(boidsInView);

        //targetVec计算
        targetVec = manager.separateScale * separateVec + alignVec * manager.alignScale + cohensionVec * manager.cohensionScale;
        currentNearestDis = Mathf.Clamp01(-Mathf.Exp(-(currentNearestDis - manager.nearestDst) * 20) + 1);
        targetVec = Vector3.Lerp(separateVec, targetVec, currentNearestDis);

        currentTarget = targetVec;


        //targetVec = forwardVector;
        targetVec.Normalize();

        TurnTo(targetVec, turnSpeed);
    }

    //分离
    //*简化了pushScale计算；将距离放在输出中
    Vector4 Separate(GameObject partner)
    {
        Vector3 distanceVec = this.transform.position - partner.transform.position;
        float distance = distanceVec.magnitude;

        float pushScale = ( (manager.boidViewDst - distance) / manager.boidViewDst ) * 3;                 //根据距离确定 ‘这个partner’ 影响forward改变的程度

        Vector3 pushVec = pushScale * distanceVec.normalized;
        Vector4 res = new Vector4(pushVec.x, pushVec.y, pushVec.z, distance);

        return res;
    }

    //对齐
    //已转换
    Vector3 Align(GameObject partner)
    {
        return partner.transform.forward;
    }

    //聚合
    //已转换
    Vector3 Cohension(List<GameObject> partners)
    {
        Vector3 averagePos = Vector3.zero;
        int parnersInViewNum = 0;
        foreach (GameObject partner in partners)
        {
            if (partner == this.gameObject) continue;
            if (IsOutOfView(partner, manager.boidViewDstConhension)) continue;
            averagePos += partner.transform.position;
            parnersInViewNum += 1;
        }
        if (parnersInViewNum > 0)
        {
            averagePos /= parnersInViewNum;
            Vector3 cohensionVec = averagePos - this.transform.position;
            return cohensionVec.normalized;
        }
        else
        {
            return transform.forward;
        }
    }

    //转向
    public void TurnTo(Vector3 targetDirection, float turnSpeed)
    {
        if (targetDirection.sqrMagnitude < 0.0001f) return; // 防止零向量

        Quaternion targetRot = Quaternion.LookRotation(targetDirection, Vector3.up);
        transform.rotation = Quaternion.Slerp(
            transform.rotation,
            targetRot,
            turnSpeed * Time.deltaTime
        );
    }

    //已转换
    bool IsOutOfView(GameObject partner, float viewDst)
    {
        Vector3 distanceVec = partner.transform.position - this.transform.position;
        bool isOutOfDst = distanceVec.magnitude > viewDst;

        float angle = Vector3.Angle(this.transform.forward, distanceVec);

        bool isOutOfAngle = angle >= manager.boidViewAngle;

        return isOutOfDst || isOutOfAngle;

    }

    void OnDrawGizmos()
    {
        if (DRAW_GIZMOS)
        {
            // 设置线条颜色
            Gizmos.color = Color.blue;

            Gizmos.DrawLine(transform.position, transform.position + transform.forward);

            Gizmos.color = Color.red;

            Gizmos.DrawLine(transform.position, transform.position + currentTarget);

        }

    }
}
