using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.Serialization.Formatters.Binary;
using System.IO;
using System.Linq;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class ElectricityLineRenderer : MonoBehaviour
{

    [Header("Line Properties")]
    public Material lineMaterial;
    public float vertexSpacing = 0.3f;
    private const int maxVertexCount = 300;


    public ElectricityLineData defaultLineData = new ElectricityLineData();

    public int linesPoolAmount = 5;
    private const int maxPoolSize = 10;


    [Header("Lights")]
    public float startLightRadius = 4f;
    public float midLightRadius = 7f;
    public float endLightRadius = 4f;
    public float lightBrightness = 2f;



    public struct LineCombo
    {
        public IEnumerator lineEnumerator;
        public LineRenderer lineRenderer;

        public Light startLight;
        public Light midLight;
        public Light endLight;

        [SerializeField] public ElectricityLineData lineData;
    }

    public LineCombo[] lineCombos;

    private bool initialized = false;
    void Awake()
    {
        Initialize();
    }

    private void Initialize()
    {
        if (linesPoolAmount > maxPoolSize)
            linesPoolAmount = maxPoolSize;

        lineCombos = new LineCombo[linesPoolAmount];
        for (int i = 0; i < linesPoolAmount; i++)
        {
            GameObject lineRendereGO = new GameObject("line");
            lineRendereGO.hideFlags = HideFlags.HideInHierarchy;
            lineCombos[i].lineRenderer = lineRendereGO.AddComponent<LineRenderer>();
            lineCombos[i].lineRenderer.transform.SetParent(transform);
            lineCombos[i].lineRenderer.sharedMaterial = lineMaterial;
            lineCombos[i].lineRenderer.enabled = false;

            lineCombos[i].startLight = new GameObject("startlight").AddComponent<Light>();
            lineCombos[i].startLight.gameObject.hideFlags = HideFlags.HideInHierarchy;
            lineCombos[i].startLight.transform.SetParent(lineRendereGO.transform);
            lineCombos[i].startLight.type = LightType.Point;
            lineCombos[i].startLight.range = startLightRadius;
            lineCombos[i].startLight.enabled = false;

            lineCombos[i].midLight = new GameObject("midLight").AddComponent<Light>();
            lineCombos[i].midLight.gameObject.hideFlags = HideFlags.HideInHierarchy;
            lineCombos[i].midLight.transform.SetParent(lineRendereGO.transform);
            lineCombos[i].midLight.type = LightType.Point;
            lineCombos[i].midLight.range = startLightRadius;
            lineCombos[i].midLight.enabled = false;

            lineCombos[i].endLight = new GameObject("endLight").AddComponent<Light>();
            lineCombos[i].endLight.gameObject.hideFlags = HideFlags.HideInHierarchy;
            lineCombos[i].endLight.transform.SetParent(lineRendereGO.transform);
            lineCombos[i].endLight.type = LightType.Point;
            lineCombos[i].endLight.range = startLightRadius;
            lineCombos[i].endLight.enabled = false;

        }

        initialized = true;
    }

    public void DisableEnableLightAndLineRenderer(bool enabled)
    {
        lineCombos.ToList().ForEach(x => 
        {
            x.lineRenderer.gameObject.SetActive(enabled);
            x.startLight.gameObject.SetActive(enabled);
            x.midLight.gameObject.SetActive(enabled);
            x.endLight.gameObject.SetActive(enabled);
        });
    }

    public Vector3 GetBezierCurvePosition(float t, Vector3 p0, Vector3 p1, Vector3 p2)
    {
        p1 += p1 - ((p2) * 0.5f) - (p0 * 0.5f); // force through midpoint


        return (
            (1f - t) * (1f - t) * p0) // control point 1 (start)
            + (2f * (1f - t) * t * p1) // control point 2 (middle)
            + ((t * t) * p2 // control point 3 (end)
            )
        ;
    }

    private int useLine = 0;



    [System.Serializable]
    public class ElectricityLineData
    {
        public float fadeTime = 0.25f;
        public Gradient colorAlongLength;
        public Gradient colorOverLife;
        public float brightnessMultiplier = 1f;
        public bool useStartLight = true;
        public bool useMidLight = true;
        public bool useEndLight = true;
        public float maxWidth = 0.1f;
        public AnimationCurve widthCurve;
        public float maxOffsetStrength = 0.6f;
        public AnimationCurve offsetCurve;
        public float movementStrength = 0.1f;

        public ElectricityLineData()
        {
            colorAlongLength = DefaultColorAlongLength();
            colorOverLife = DefaultColorOverLife();
            widthCurve = DefaultWidthCurve();
            offsetCurve = DefaultWidthCurve();

        }
        public ElectricityLineData(ElectricityLineData copyLineData)
        {
            fadeTime = copyLineData.fadeTime;
            colorAlongLength = copyLineData.colorAlongLength;
            colorOverLife = copyLineData.colorOverLife;
            brightnessMultiplier = copyLineData.brightnessMultiplier;
            useStartLight = copyLineData.useStartLight;
            useMidLight = copyLineData.useMidLight;
            useEndLight = copyLineData.useEndLight;
            maxWidth = copyLineData.maxWidth;
            widthCurve = copyLineData.widthCurve;
            maxOffsetStrength = copyLineData.maxOffsetStrength;
            offsetCurve = copyLineData.offsetCurve;
            movementStrength = copyLineData.movementStrength;
        }


        public ElectricityLineData(Color color)
        {
            colorAlongLength = new Gradient();
            colorAlongLength.SetKeys(new GradientColorKey[] { new GradientColorKey(color, 0f) }, new GradientAlphaKey[] { new GradientAlphaKey(1f, 0f) });
            colorOverLife = DefaultColorOverLife();
            widthCurve = DefaultWidthCurve();
            offsetCurve = DefaultWidthCurve();

        }

        public ElectricityLineData(Gradient color)
        {
            colorAlongLength = color;
            colorOverLife = DefaultColorOverLife();
            widthCurve = DefaultWidthCurve();
            offsetCurve = DefaultWidthCurve();

        }

        public ElectricityLineData(Color color, float width, float brightness)
        {
            colorAlongLength = new Gradient();
            colorAlongLength.SetKeys(new GradientColorKey[] { new GradientColorKey(color, 0f) }, new GradientAlphaKey[] { new GradientAlphaKey(1f, 0f) });
            colorOverLife = DefaultColorOverLife();
            widthCurve = DefaultWidthCurve();
            offsetCurve = DefaultWidthCurve();

            maxWidth = width;
            brightnessMultiplier = brightness;
        }

        public ElectricityLineData(Gradient color, float width, float brightness)
        {
            colorAlongLength = color;
            colorOverLife = DefaultColorOverLife();
            widthCurve = DefaultWidthCurve();
            offsetCurve = DefaultWidthCurve();
            maxWidth = width;
            brightnessMultiplier = brightness;
        }

        public Gradient DefaultColorAlongLength()
        {
            GradientColorKey[] colorKey;
            GradientAlphaKey[] alphaKey;

            //Set Default Color Along Length Gradient
            colorKey = new GradientColorKey[3];
            colorKey[0].color = new Color(0.1f, 0.1f, 1f);
            colorKey[0].time = 0f;
            colorKey[1].color = new Color(0.18f, 0.9f, 0.92f);
            colorKey[1].time = 0.5f;
            colorKey[2].color = new Color(0.1f, 0.1f, 1f);
            colorKey[2].time = 1f;

            alphaKey = new GradientAlphaKey[4];
            alphaKey[0].alpha = 0f;
            alphaKey[0].time = 0f;
            alphaKey[1].alpha = 1f;
            alphaKey[1].time = 0.15f;
            alphaKey[2].alpha = 1f;
            alphaKey[2].time = 0.85f;
            alphaKey[3].alpha = 0f;
            alphaKey[3].time = 1f;

            Gradient defaultColorAlongLength = new Gradient();
            defaultColorAlongLength.SetKeys(colorKey, alphaKey);
            return defaultColorAlongLength;

        }

        public Gradient DefaultColorOverLife()
        {
            GradientColorKey[] colorKey;
            GradientAlphaKey[] alphaKey;

            //Set Color Over Life Gradient
            colorKey = new GradientColorKey[3];
            colorKey[0].color = Color.black;
            colorKey[0].time = 0.088f;
            colorKey[1].color = Color.white;
            colorKey[1].time = 0.35f;
            colorKey[2].color = Color.black;
            colorKey[2].time = 0.5f;

            alphaKey = new GradientAlphaKey[3];
            alphaKey[0].alpha = 1f;
            alphaKey[0].time = 0.33f;
            alphaKey[1].alpha = 0.45f;
            alphaKey[1].time = 0.85f;
            alphaKey[2].alpha = 0f;
            alphaKey[2].time = 1f;

            Gradient colorOverLife = new Gradient();
            colorOverLife.SetKeys(colorKey, alphaKey);
            return colorOverLife;


        }

        public AnimationCurve DefaultWidthCurve()
        {
            //Set Width Curve
            AnimationCurve widthCurve = new AnimationCurve(new Keyframe(0, 0), new Keyframe(0.5f, 1), new Keyframe(1, 0));
            return widthCurve;
        }
    }



    public void LightningOn(Vector3 startPos, Vector3 endPos, Vector3? midPos, Color color)
    {
        ElectricityLineData newLineData = new ElectricityLineData(defaultLineData);
        newLineData.colorAlongLength = new Gradient();
        newLineData.colorAlongLength.SetKeys(new GradientColorKey[] { new GradientColorKey(color, 0f) }, new GradientAlphaKey[] { new GradientAlphaKey(1f, 0f) });

        LightningOn(startPos, endPos, midPos, newLineData);
    }

    public void LightningOn(Vector3 startPos, Vector3 endPos, Vector3? midPos, Gradient colorAlongLength)
    {
        ElectricityLineData newLineData = new ElectricityLineData(defaultLineData);
        newLineData.colorAlongLength = colorAlongLength;
        LightningOn(startPos, endPos, midPos, newLineData);
    }




    public void LightningOn(Vector3 startPos, Vector3 endPos, Vector3? midPos = null, ElectricityLineData newLineData = null, bool allowLights = true)
    {
        if (!initialized)
            Initialize();

        useLine++;
        if (useLine >= lineCombos.Length || useLine < 0)
            useLine = 0;

    
        if (lineCombos[useLine].lineEnumerator != null)
        {
            StopCoroutine(lineCombos[useLine].lineEnumerator);

            lineCombos[useLine].lineRenderer.enabled = false;
            lineCombos[useLine].startLight.enabled = false;
            lineCombos[useLine].midLight.enabled = false;
            lineCombos[useLine].endLight.enabled = false;

        }

        if(newLineData != null)
            lineCombos[useLine].lineData = newLineData;
        else
            lineCombos[useLine].lineData = defaultLineData;

        lineCombos[useLine].lineEnumerator = LightningEnumerator(lineCombos[useLine], startPos, endPos, midPos, allowLights);
        StartCoroutine(lineCombos[useLine].lineEnumerator);
    }


    IEnumerator LightningEnumerator(LineCombo line, Vector3 startPosition, Vector3 endPosition, Vector3? midPos = null, bool allowLights = true)
    {
        line.lineRenderer.enabled = true;

        GradientAlphaKey[] alphaKeys = line.lineData.colorAlongLength.alphaKeys;
        GradientColorKey[] colorKeys = line.lineData.colorAlongLength.colorKeys;


        float length = Vector3.Distance(startPosition, endPosition);

        int vertexCount = (int)(length / Mathf.Abs(vertexSpacing));
        if (vertexCount > maxVertexCount) vertexCount = maxVertexCount;

        line.lineRenderer.positionCount = vertexCount;
        Vector3[] positions = new Vector3[vertexCount];
        Vector3 direction = (endPosition - startPosition).normalized;

        Vector3 midPosition = (endPosition + startPosition) * 0.5f;
        if (midPos != null)
            midPosition = midPos.Value;


        for (int i = 0; i < vertexCount; i++)
        {
            float percentAlong = (float)i / (float)vertexCount;

            Vector3 nextPosition;
            if (midPos == null)
                nextPosition = Vector3.Lerp(startPosition, endPosition, percentAlong);
            else
            {
                nextPosition = GetBezierCurvePosition(percentAlong, startPosition, midPosition, endPosition);
            }

            Vector3 randomOffset = Random.insideUnitSphere * line.lineData.offsetCurve.Evaluate(percentAlong) * line.lineData.maxOffsetStrength;
            float offsetTweak = 1f - Mathf.Abs(Vector3.Dot(randomOffset.normalized, direction));
            positions[i] = nextPosition + (randomOffset * offsetTweak);

        }

        line.lineRenderer.widthMultiplier = line.lineData.maxWidth;
        line.lineRenderer.widthCurve = line.lineData.widthCurve;
        line.lineRenderer.SetPositions(positions);

        Color startColour = line.lineData.colorAlongLength.Evaluate(0.1f);
        Color midColour = line.lineData.colorAlongLength.Evaluate(0.5f);
        Color endColour = line.lineData.colorAlongLength.Evaluate(0.9f);


        //float brightnessIntensity = maxBrightness * lightIntensityScale;
        if (allowLights)
        {
            if (line.lineData.useStartLight)
            {
                line.startLight.transform.position = GetBezierCurvePosition(0.1f, startPosition, midPosition, endPosition);
                line.startLight.enabled = true;
                line.startLight.intensity = lightBrightness;
                line.startLight.range = startLightRadius;
            }
            if (line.lineData.useMidLight)
            {
                line.midLight.transform.position = GetBezierCurvePosition(0.5f, startPosition, midPosition, endPosition);
                line.midLight.enabled = true;
                line.midLight.intensity = lightBrightness;
                line.midLight.range = midLightRadius;
            }
            if (line.lineData.useEndLight)
            {
                line.endLight.transform.position = GetBezierCurvePosition(0.9f, startPosition, midPosition, endPosition);
                line.endLight.enabled = true;
                line.endLight.intensity = lightBrightness;
                line.endLight.range = endLightRadius;
            }
        }


        Vector3 moveDirection = midPosition - ((endPosition + startPosition) * 0.5f);


        float clock = line.lineData.fadeTime;
        while (clock > 0f)
        {
            clock -= Time.deltaTime;
            float life = 1f - (clock / line.lineData.fadeTime);
            Color lineColour = line.lineData.colorOverLife.Evaluate(life);


            for (int i = 0; i < alphaKeys.Length; i++)
            {
                alphaKeys[i].alpha = line.lineData.colorAlongLength.alphaKeys[i].alpha * lineColour.a;
            }
            for (int i = 0; i < colorKeys.Length; i++)
            {
                colorKeys[i].color = line.lineData.colorAlongLength.colorKeys[i].color * lineColour * line.lineData.brightnessMultiplier;
            }

            Gradient adjustedGradient = new Gradient();
            adjustedGradient.SetKeys(colorKeys, alphaKeys);

            line.lineRenderer.colorGradient = adjustedGradient;
            if (allowLights)
            {
                if (line.lineData.useStartLight)
                    line.startLight.color = startColour * lineColour.a * line.lineData.brightnessMultiplier;
                if (line.lineData.useMidLight)
                    line.midLight.color = midColour * lineColour.a * line.lineData.brightnessMultiplier;
                if (line.lineData.useEndLight)
                    line.endLight.color = endColour * lineColour.a * line.lineData.brightnessMultiplier;
            }



            //move up over time

            for (int i = 0; i < positions.Length; i++)
            {
                float percentAlong = (float)i / (float)vertexCount;

                positions[i] += (moveDirection.normalized * line.lineData.offsetCurve.Evaluate(percentAlong) * line.lineData.movementStrength * lineColour.r);
            }

            line.lineRenderer.SetPositions(positions);


            yield return null;

        }
        line.lineRenderer.enabled = false;


        line.startLight.enabled = false;
        line.midLight.enabled = false;
        line.endLight.enabled = false;

    }


#if UNITY_EDITOR

    void Reset()
    {
        SetupDefaults();
    }

#endif

//    [ContextMenu("Setup Defaults")]
    public void SetupDefaults()
    {

       // defaultLineData = new ElectricityLineData();

#if UNITY_EDITOR
        //Load material
        string[] guids = AssetDatabase.FindAssets("ElectricityLineMat t:Material");
        lineMaterial = (Material)AssetDatabase.LoadAssetAtPath(AssetDatabase.GUIDToAssetPath(guids[0]), typeof(Material));
#endif

    }


}



