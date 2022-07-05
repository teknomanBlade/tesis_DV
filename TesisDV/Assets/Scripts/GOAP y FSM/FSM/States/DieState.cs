using System;
using FSM;

public class DieState : MonoBaseState
{
    public override void UpdateLoop()
    {

    }

    public override IState ProcessInput()
    {
        return this;
    }
}
