using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using System;

public class MiniMap : MonoBehaviour
{
    // Start is called before the first frame update
    public List<Gray> grays;
    public List<Vector3> wayPointsOfAllGrey;

    public List<Tuple<Gray, List<Vector3>>> grayWithGreyPoints;

    public GameObject player;

    public List<GameObject> lineRenderers = new List<GameObject>();

    public GameObject prefabIndicador;
    public int ShowGreyCount;
    void Start()
    {
        //lineRenderers.Select(x =>
        //{
        //    x.startWidth = 0.15f;
        //    x.endWidth = 0.15f;
        //    x.positionCount = 0;
        //    return x;
        //}).ToList();
        //IA PARCIAL DOS
        var listOfCollider = GetComponentsInChildren<BoxCollider>();

        listOfCollider.Select(x => x.enabled = false).ToList();

        player = FindObjectOfType<Player>().gameObject;
    }

    // Update is called once per frame
    void Update()
    {
        if (grayWithGreyPoints != null)
            StartCoroutine("DrayLGrayineRenderer");
    }
    //IA2 -P1
    //IATP2 -P1
    //IA-TP2 -P1
    public void DrawWayPointInMiniMap()
    {
        try
        {
            wayPointsOfAllGrey = grays.Where(x => x != x.dead || x != null || x.gameObject != null).OrderBy(x => Vector3.Distance(x.gameObject.transform.position, player.transform.position)).SelectMany(x => x._waypoints).ToList();

            grayWithGreyPoints = grays.Aggregate(new List<Tuple<Gray, List<Vector3>>>(), (myGrayWithWayPoint, myGray) =>
            {
                if (myGray != myGray.dead)
                    myGrayWithWayPoint.Add(new Tuple<Gray, List<Vector3>>(myGray, myGray._waypoints.ToList()));


                return myGrayWithWayPoint;
            });
        }
        catch (Exception ex)
        { }
    }

    IEnumerator DrayLGrayineRenderer()
    {
        if (grayWithGreyPoints == null || grayWithGreyPoints.Count == 0)
            yield return new WaitForSeconds(0.5f);

        //for (int i = 0; i < grayWithGreyPoints.Count; i++)
        //{
        //    Debug.Log(grayWithGreyPoints[i].Item1 + " " + grayWithGreyPoints[i].Item2.Count);
        //}

        for (int x = 0; x < grayWithGreyPoints.Count; x++)
        {
            Debug.Log("grayWithGreyPoints " + grayWithGreyPoints.Count);
            var waypoints = grayWithGreyPoints[x].Item2;

            if (waypoints == null || waypoints.Count < 1)
                yield return new WaitForSeconds(0.5f);

            Debug.Log("lineRenderers " + lineRenderers.Count);

            if (lineRenderers.Count > x)
            {
                lineRenderers[x].GetComponent<LineRenderer>().positionCount = waypoints.Count;
                lineRenderers[x].GetComponent<LineRenderer>().SetPosition(0, waypoints[0]);

                for (int i = 1; i < waypoints.Count; i++)
                {
                    Vector3 pointPosition = new Vector3(waypoints[i].x, waypoints[i].y, waypoints[i].z);
                    lineRenderers[x].GetComponent<LineRenderer>().SetPosition(i, pointPosition);
                }
            }
        }
        yield return new WaitForSeconds(0.5f);
    }

    public void AddLineRenderer(LineRenderer lineRenderer)
    {
        //LineRenderer lineRenderer = new LineRenderer();


        lineRenderers.Add(lineRenderer.gameObject);
    }

    public void RemoveGray(Gray gray)
    {
        grays.Remove(gray);

    }

}
