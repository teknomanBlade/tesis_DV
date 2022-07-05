using UnityEngine;
using System;
using FSM;
using UnityEngine.AI;
public class FleeingState : MonoBaseState
{
    public float movingSpeed;
    private Vector3 _exitPos;
    private Vector3 _shipDistance;
    private NavMeshAgent _navMeshAgent;
    public Vector3[] _waypoints;
    private bool pathIsCreated;
    private MiniMap miniMap;
    private int _currentWaypoint = 0;
    private bool canCreatePath;
    void Start()
    {
        Vector3 aux = new Vector3(transform.position.x, 0f, transform.position.z);
        _exitPos = aux;
    }
    public override void UpdateLoop()
    {
        
    }

     public override IState ProcessInput()
    {
       return this;
    }
}
