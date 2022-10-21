using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class ElectricityArc : MonoBehaviour
{
    public ElectricityLineRenderer electricityLineRenderer;

    [Header("Positions")]
    public Transform endPositionTransform;
    public Transform midPositionTransform;

    public float randomMidPositionRadius = 0f;
    [Range(-1f, 5f)] public float randomMidPositionSquash = 0f;

    [Header("Debug")]
    public KeyCode debugFireKey = KeyCode.Space;
    public bool showGizmos = true;
    private Vector3?[] lastArc;

    //public bool startLight = true;
    //public bool midLight = true;
    //public bool endLight = true;

    [SerializeField] public ElectricityLineRenderer.ElectricityLineData electricity;

    public bool randomlyOffsetGradient = false;

    [Range(1, 5)] public int simultaneousLines = 1;
    //public enum OverrideColor
    //{
    //    none,
    //    color,
    //    gradient,
    //    gradientRandomOffset
    //}
    //[Header("Colors")]
    //public Color color;
    //public Gradient gradient;

    //public OverrideColor overrideColor;

    private void OnValidate()
    {
        if (!electricityLineRenderer)
            electricityLineRenderer = GetComponent<ElectricityLineRenderer>();

        if (!endPositionTransform)
            endPositionTransform = transform.Find("end");

        if (!midPositionTransform)
            midPositionTransform = transform.Find("mid");
    }

    public void Update()
    {
        if (Input.GetKeyDown(debugFireKey))
        {
            Zap();
        }

    }

    public void Zap()
    {
        if (!electricityLineRenderer)
            return;

        Vector2 endPos = transform.position + transform.forward;
        if (endPositionTransform != null)
            endPos = endPositionTransform.position;

        Vector3 midPosition = (endPositionTransform.position + transform.position) * 0.5f;

        if (midPositionTransform)
            midPosition = midPositionTransform.position;

        bool allowLightFirstLightOnly = true;

        for (int k = 0; k < simultaneousLines; k++)
        {


            if (randomMidPositionRadius > 0f)
            {
                Vector3 position = Random.insideUnitSphere * randomMidPositionRadius;
                Vector3 scale = new Vector3(1f, 1f, 1f * (1f + randomMidPositionSquash));
                Matrix4x4 m = Matrix4x4.TRS(midPosition, Quaternion.LookRotation(transform.position - endPositionTransform.position), scale);
                midPosition = m.MultiplyPoint3x4(position);
                lastArc = new Vector3?[3] { transform.position, midPosition, endPositionTransform.position };
            }


            if (randomlyOffsetGradient)
            {
                float randomOffset = Random.Range(0f, 1f);
                Gradient offsetGradient = new Gradient();
                GradientColorKey[] colorKey = electricity.colorAlongLength.colorKeys;
                GradientAlphaKey[] alphaKey = electricity.colorAlongLength.alphaKeys;
                for (int i = 0; i < colorKey.Length; i++)
                {
                    float newTime = colorKey[i].time + randomOffset;
                    if (newTime > 1f)
                        newTime -= 1f;
                    colorKey[i].time = newTime;
                }
                //we probably don't want to offset the alpha as that's used for fading the lightning at the ends, unless we separate that off into it's own curve.
                //for (int i = 0; i < alphaKey.Length; i++)
                //{
                //    float newTime = alphaKey[i].time + randomOffset;
                //    if (newTime > 1f)
                //        newTime -= 1f;
                //    alphaKey[i].time = newTime;
                //}
                offsetGradient.SetKeys(colorKey, alphaKey);

                ElectricityLineRenderer.ElectricityLineData offsetGradientLine = new ElectricityLineRenderer.ElectricityLineData(electricity);
                offsetGradientLine.colorAlongLength = offsetGradient;

                electricityLineRenderer.LightningOn(transform.position, endPositionTransform.position, midPosition, offsetGradientLine, allowLightFirstLightOnly);

            }
            else
                electricityLineRenderer.LightningOn(transform.position, endPositionTransform.position, midPosition, electricity, allowLightFirstLightOnly);

            allowLightFirstLightOnly = false;

        }
    }

    private void OnDrawGizmos()
    {
        if (!showGizmos || !electricityLineRenderer)
            return;

        if (endPositionTransform)
        {
            if (!midPositionTransform)
                Gizmos.DrawLine(transform.position, endPositionTransform.position);
            else
            {
                int segments = 10;
                Vector3 previousPosition = transform.position;


                for (int i = 0; i <= segments; i++)
                {
                    float t = (float)i / (float)segments;
                    Vector3 nextPosition = electricityLineRenderer.GetBezierCurvePosition(t, transform.position, midPositionTransform.position, endPositionTransform.position);
                    Gizmos.DrawLine(previousPosition, nextPosition);
                    previousPosition = nextPosition;
                }

                if (lastArc != null)
                {
                    Vector3 previousPositionLastLine = lastArc[0].Value;

                    for (int i = 0; i <= segments; i++)
                    {
                        float t = (float)i / (float)segments;
                        Vector3 nextPosition = electricityLineRenderer.GetBezierCurvePosition(t, lastArc[0].Value, lastArc[1].Value, lastArc[2].Value);
                        Gizmos.color = Color.blue;
                        Gizmos.DrawLine(previousPositionLastLine, nextPosition);
                        previousPositionLastLine = nextPosition;
                    }
                }
                if (randomMidPositionRadius > 0f)
                {
                    Vector3 scale = new Vector3(1f, 1f, 1f * (1f + randomMidPositionSquash));
                    Gizmos.matrix = Matrix4x4.TRS(midPositionTransform.position, Quaternion.LookRotation(transform.position - endPositionTransform.position), scale);
                    Gizmos.color = Color.yellow;

                    Gizmos.DrawWireSphere(Vector3.zero, randomMidPositionRadius);


                }
            }
        }

    }
}
