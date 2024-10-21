using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class ElectricityRandomRays : MonoBehaviour
{

    public ElectricityLineRenderer electricityLineRenderer;

    public float internalRadius = 1f;
    public float raycastRadius = 5f;

    public float minTime = 0.1f;
    public float maxTime = 0.5f;


    [Range(1, 10)] public int maxSimultanousRays = 3;
    [Range(0f, 180f)] public float raycastAngle = 180f;

    // confine the raycast searching to objects in the direction of transform.forwar. 180 = full sphere.


    [SerializeField] public ElectricityLineRenderer.ElectricityLineData hitNothingLine;

    [Range(0f, 2f)] public float randomMidRadiusViaLength = 0.5f;
    [Range(-1f, 0f)] public float randomMidPositionSquash = -0.5f;

    [Range(0f, 1f)] public float zapOnHitNothingChance = 0.5f;

    //from https://answers.unity.com/questions/58692/randomonunitsphere-but-within-a-defined-range.html
    public static Vector3 GetPointOnUnitSphereCap(Quaternion targetDirection, float angle)
    {
        var angleInRad = Random.Range(0.0f, angle) * Mathf.Deg2Rad;
        var PointOnCircle = (Random.insideUnitCircle.normalized) * Mathf.Sin(angleInRad);
        var V = new Vector3(PointOnCircle.x, PointOnCircle.y, Mathf.Cos(angleInRad));
        return targetDirection * V;
    }

    //from https://answers.unity.com/questions/58692/randomonunitsphere-but-within-a-defined-range.html
    public static Vector3 GetPointOnUnitSphereCap(Vector3 targetDirection, float angle)
    {
        return GetPointOnUnitSphereCap(Quaternion.LookRotation(targetDirection), angle);
    }


    void ZapElectricity(Vector3 startPos, Vector3 endPos, ElectricityLineRenderer.ElectricityLineData lineData)
    {
        //Debug.Log(lineData != null);

        Vector3 midPos = (startPos + endPos) * 0.5f;

        if (randomMidRadiusViaLength > 0f)
        {
            Vector3 position = Random.insideUnitSphere * randomMidRadiusViaLength * Vector3.Distance(startPos, endPos);
            Vector3 scale = new Vector3(1f, 1f, 1f * (1f + randomMidPositionSquash));
            Matrix4x4 m = Matrix4x4.TRS(midPos, Quaternion.LookRotation(startPos - endPos), scale);
            midPos = m.MultiplyPoint3x4(position);
        }

        electricityLineRenderer.LightningOn(startPos, endPos, midPos, lineData);

    }

    private void Start()
    {

        if (electricityLineRenderer == null)
            electricityLineRenderer = GetComponent<ElectricityLineRenderer>();

        if (electricityLineRenderer)
            StartCoroutine(RayChecking());
    }


    IEnumerator RayChecking()
    {

        while (true)
        {

            int raysLeft = maxSimultanousRays;


            for (int i = 0; i < maxSimultanousRays; i++)
            {
                Vector3 randomRayDirection = GetPointOnUnitSphereCap(transform.forward, raycastAngle);
                Vector3 originPosition = transform.position + randomRayDirection * internalRadius;
                Vector3 randomEndPosition = originPosition + (randomRayDirection * raycastRadius * Random.RandomRange(0.1f, 1f));

                if (zapOnHitNothingChance >= Random.Range(0f, 1f))
                    ZapElectricity(originPosition, randomEndPosition, hitNothingLine);
            }

            float waitSeconds = Random.Range(minTime, maxTime);
            yield return new WaitForSeconds(waitSeconds);


        }
    }
#if UNITY_EDITOR

    [Header("Debug")]
    public bool showDebug = true;
    private void OnDrawGizmos()
    {
        if (showDebug)
        {
            Gizmos.color = Color.yellow;

            Gizmos.DrawWireSphere(transform.position, internalRadius);

            int circleSegments = 10;
            for (int i = 0; i < circleSegments; i++)
            {
                float angle = (180f / circleSegments) * (i + 1);

                if (angle < raycastAngle)
                    Handles.color = new Color(0f, 1f, 0f, 0.3f);
                else
                    Handles.color = new Color(1f, 0f, 0f, 0.3f);
                angle *= Mathf.Deg2Rad;
                float circleRadius = Mathf.Sin(angle) * raycastRadius;
                float circleOffset = Mathf.Cos(angle) * raycastRadius;
                Handles.CircleHandleCap(0, transform.position + transform.forward * circleOffset, Quaternion.LookRotation(transform.forward), circleRadius, EventType.Repaint);

            }

            Handles.color = Color.white;
            float coneRadius = Mathf.Sin(Mathf.Deg2Rad * raycastAngle) * raycastRadius;
            float coneLength = Mathf.Cos(Mathf.Deg2Rad * raycastAngle) * raycastRadius;
            Handles.CircleHandleCap(0, transform.position + transform.forward * coneLength, Quaternion.LookRotation(transform.forward), coneRadius, EventType.Repaint);

        }

    }
#endif
}
