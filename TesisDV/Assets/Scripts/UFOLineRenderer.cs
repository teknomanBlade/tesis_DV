using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class UFOLineRenderer : MonoBehaviour
{
    private Cat _cat;
    [SerializeField] private GameObject owner;
    [SerializeField] private LineRenderer lineRenderer;
    private float _nodeYPosition = 0.26f;

    #region Pathfinding

    private Pathfinding _pf;
    public List<Node> myPath;
    private Node startingPoint;
    private Node endingPoint;
    
    #endregion

    void Start()
    {
        _pf = new Pathfinding();
        transform.position = owner.transform.position;
        _cat = GameVars.Values.Cat;
        GetAStarPath();
    }

    private void DrawLineRenderer(List<Node> waypoints) 
    {
        lineRenderer.positionCount = waypoints.Count;

        for (int i = 0; i < waypoints.Count; i++)
        {
            Vector3 pointPosition = new Vector3(waypoints[i].transform.position.x, _nodeYPosition, waypoints[i].transform.position.z);
            lineRenderer.SetPosition(i, pointPosition);
        }
    }

    public void GetAStarPath()
    {
        myPath = new List<Node>();
        if (transform == null) return;
        
        startingPoint = PathfindingManager.Instance.GetClosestNode(transform.position);
        if(gameObject.activeSelf)
            StartCoroutine(nameof(WaitToPositionSet));

    }

    IEnumerator WaitToPositionSet() 
    {
        yield return new WaitUntil(() => _cat.StartingPosition != Vector3.zero);
        endingPoint = PathfindingManager.Instance.GetClosestNode(_cat.StartingPosition);

        myPath = _pf.ConstructPathAStar(endingPoint, startingPoint);
        DrawLineRenderer(myPath.AsEnumerable().Reverse().ToList());
    }
}
