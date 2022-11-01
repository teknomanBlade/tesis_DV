using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class UFOLineRenderer : MonoBehaviour
{
    private Cat _cat;
    [SerializeField] private GameObject owner;
    [SerializeField] private NavMeshAgent _navMeshAgent;
    [SerializeField] private LineRenderer lineRenderer;

    void Start()
    {
        transform.position = owner.transform.position;
        _cat = GameVars.Values.Cat;

        CalculatePath(_cat.GetStartingPosition());
    }

    private void DrawLineRenderer(Vector3[] waypoints) 
    {
        lineRenderer.positionCount = waypoints.Length;
        lineRenderer.SetPosition(0, waypoints[0]);

        for (int i = 1; i < waypoints.Length; i++)
        {
            Vector3 pointPosition = new Vector3(waypoints[i].x, waypoints[i].y, waypoints[i].z);
            lineRenderer.SetPosition(i, pointPosition);
        }
    }

    private void CalculatePath(Vector3 targetPosition)
    {
        //_navMeshAgent.ResetPath();
        NavMeshPath path = new NavMeshPath();
        if (NavMesh.CalculatePath(owner.transform.position, targetPosition, NavMesh.AllAreas, path))
        {
            //_navMeshAgent.SetPath(path); Esta linea tiraba null pero no es necesaria para mostrar el LineRenderer.

            DrawLineRenderer(path.corners);  
        }
    }
}
