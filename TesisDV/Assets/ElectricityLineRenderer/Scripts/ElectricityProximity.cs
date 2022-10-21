using System.Collections;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class ElectricityProximity : MonoBehaviour
{


    public ElectricityLineRenderer electricityLineRenderer;

    public LayerMask zapThisLayer;

    public float internalRadius = 1f;
    public float raycastRadius = 5f;

    public float minTime = 0.1f;
    public float maxTime = 0.5f;


    [Range(1,10)]public int maxSimultanousRays = 3;
    [Range(0f, 180f)] public float raycastAngle = 180f; // confine the raycast searching to objects in the direction of transform.forwar. 180 = full sphere.


    [Header("Colors")]
    [SerializeField] public ElectricityLineRenderer.ElectricityLineData hitClosestLine;
    [SerializeField] public ElectricityLineRenderer.ElectricityLineData hitNearbyLine;
    [SerializeField] public ElectricityLineRenderer.ElectricityLineData hitNothingLine;


    [Range(0f,1f)] public float zapOnHitNothingChance = 0.5f;

    [Range(0f, 2f)] public float randomMidRadiusViaLength = 0.5f;
    [Range(-1f, 0f)] public float randomMidPositionSquash = -0.5f;

    private Collider thisCollider;

    [Header("Debug")]
    public bool showDebug = true;
    private void OnValidate()
    {
        if (!electricityLineRenderer)
            electricityLineRenderer = GetComponent<ElectricityLineRenderer>();
    }



    public static Vector3 GetPointOnUnitSphereCap(Quaternion targetDirection, float angle) //from https://answers.unity.com/questions/58692/randomonunitsphere-but-within-a-defined-range.html
    {
        var angleInRad = Random.Range(0.0f, angle) * Mathf.Deg2Rad;
        var PointOnCircle = (Random.insideUnitCircle.normalized) * Mathf.Sin(angleInRad);
        var V = new Vector3(PointOnCircle.x, PointOnCircle.y, Mathf.Cos(angleInRad));
        return targetDirection * V;
    }
    public static Vector3 GetPointOnUnitSphereCap(Vector3 targetDirection, float angle) //from https://answers.unity.com/questions/58692/randomonunitsphere-but-within-a-defined-range.html
    {
        return GetPointOnUnitSphereCap(Quaternion.LookRotation(targetDirection), angle);
    }

    private void Start()
    {
        thisCollider = GetComponent<Collider>();

        if (electricityLineRenderer == null)
            electricityLineRenderer = GetComponent<ElectricityLineRenderer>();

        if(electricityLineRenderer)
            StartCoroutine(RayChecking());
    }


    void ZapElectricity(Vector3 startPos, Vector3 endPos, ElectricityLineRenderer.ElectricityLineData lineData)
    {
        Vector3 midPos = (startPos + endPos) * 0.5f;

        if (randomMidRadiusViaLength > 0f)
        {
            Vector3 position = Random.insideUnitSphere * randomMidRadiusViaLength * Vector3.Distance(startPos,endPos);
            Vector3 scale = new Vector3(1f, 1f, 1f * (1f + randomMidPositionSquash));
            Matrix4x4 m = Matrix4x4.TRS(midPos, Quaternion.LookRotation(startPos - endPos), scale);
            midPos = m.MultiplyPoint3x4(position);
        }

        electricityLineRenderer.LightningOn(startPos, endPos, midPos, lineData);

    }



    IEnumerator RayChecking()
    {

        while (true)
        {

            int raysLeft = maxSimultanousRays;


            //Zap towards the nearest point on nearby colliders

            for (int i = 0; i < overlapSphereBuffer.Length; i++)
            {
                overlapSphereBuffer[i] = null;
            }

            Physics.OverlapSphereNonAlloc(transform.position, raycastRadius, overlapSphereBuffer, zapThisLayer); // add all the nearby colliders to a buffer
            for (int i = 0; i < overlapSphereBuffer.Length; i++)
            {
                if (overlapSphereBuffer[i] != null)
                {
                    bool legalForZap = (overlapSphereBuffer[i] != thisCollider); // don't zap yourself

                    MeshCollider concaveMeshCheck = overlapSphereBuffer[i] as MeshCollider;
                    if (concaveMeshCheck != null)
                        legalForZap = concaveMeshCheck.convex; // if it's a mesh collider, don't zap a concave one (via closest point, it won't work).

                    if (legalForZap)
                    {
                        Vector3 nearestPoint = Physics.ClosestPoint(transform.position, overlapSphereBuffer[i], overlapSphereBuffer[i].transform.position, overlapSphereBuffer[i].transform.rotation);
                        float angleCheck = ((Vector3.Dot(transform.forward, (nearestPoint - transform.position).normalized) + 1f) / 2f * -180f) + 180f; // remap dot product to match our 0-180 angle check

                        if (angleCheck <= raycastAngle)
                        {
                            if (Vector3.SqrMagnitude(nearestPoint - transform.position) < raycastRadius * raycastRadius)
                            {
                                if (raysLeft > 0)
                                {

                                    Vector3 direction = (nearestPoint - transform.position);
                                    Vector3 originPosition = transform.position + direction.normalized * internalRadius;

                                    ZapElectricity(originPosition, nearestPoint, hitClosestLine);
                                    if (showDebug)
                                        Debug.DrawRay(transform.position + direction.normalized * internalRadius, direction - direction.normalized * internalRadius, Color.green, 0.09f);

                                    raysLeft--;
                                }
                            }
                        }
                    }

                }
            }


            //Send out random raycasts to zap things that get hit, or just create a 'hit nothing' zap

            RaycastHit hit;

            for (int i = 0; i < raysLeft; i++)
            {

                Vector3 randomRayDirection = GetPointOnUnitSphereCap(transform.forward, raycastAngle);
                Vector3 originPosition = transform.position + randomRayDirection * internalRadius;

                if (Physics.Raycast(originPosition, randomRayDirection, out hit, raycastRadius, zapThisLayer))
                {
                    ZapElectricity(originPosition, hit.point, hitNearbyLine);

                    if (showDebug)
                        Debug.DrawRay(originPosition, hit.point, Color.green, 0.09f);
                }
                else
                {
                    Vector3 randomEndPosition = originPosition + (randomRayDirection * raycastRadius * Random.RandomRange(0.1f, 1f));
                    if (zapOnHitNothingChance >= Random.Range(0f, 1f))
                        ZapElectricity(originPosition, randomEndPosition, hitNothingLine);
                    
                    if (showDebug)
                        Debug.DrawRay(originPosition, randomEndPosition- originPosition, Color.red, 0.09f);
                }
            }

            float waitSeconds = Random.Range(minTime, maxTime);
            yield return new WaitForSeconds(waitSeconds);
        }
    }


    private Collider[] overlapSphereBuffer = new Collider[10];

#if UNITY_EDITOR

    private void OnDrawGizmos()
    {
        if (showDebug)
        {
            Gizmos.color = Color.yellow;

            Gizmos.DrawWireSphere(transform.position, internalRadius);

            int circleSegments = 10;
            for (int i = 0; i < circleSegments; i++)
            {
                float angle = (180f / circleSegments) * (i+1);

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
            Handles.CircleHandleCap(0, transform.position + transform.forward * coneLength, Quaternion.LookRotation(transform.forward),coneRadius, EventType.Repaint);

        }

    }
#endif
}
